# frozen_string_literal: true

# The entire purpose of this is for a developer to bootstrap a database with some census records exported with the
# CSV button on HistoryForge.
namespace :import do
  task census: :environment do
    year = ENV.fetch('YEAR', nil)
    raise ArgumentError('You must pass in a YEAR argument') if year.blank?

    csv_file = ENV.fetch('FILE', nil)
    raise ArgumentError('You must pass in a valid file path as the FILE argument') unless File.exist?(csv_file)

    rows_count = 0
    saved_count = 0

    Setting.load

    require 'csv'

    CSV.foreach(csv_file, headers: true) do |row|
      record = CensusRecord.for_year(year).find_or_initialize_by(
        city: row['City'],
        ward: row['Ward'],
        enum_dist: row['Enum Dist'],
        page_number: row['Sheet'],
        page_side: row['Side'],
        line_number: row['Line']
      )
      #record.sex = row['sex']
      #record.race = row['race']
      #record.institution = row['institution']
      #record.owned_or_rented = row['owned_or_rented']
      #record.mortgage = row['mortgage']
      #record.age_months = row['age_months']
      #record.marital_status = row['marital_status']
      #record.foreign_born = row['foreign_born']
      #record.naturalized_alien = row['naturalized_alien']
      #record.can_read = row['can_read']
      #record.can_write = row['can_write']
      #record.street_prefix = row['Prefix']
      #record.street_suffix = row['Suffix']
      #record.attended_school = row['attended_school']


      row.each do |key, value|
        if key == 'Locality'
          record.locality = Locality.find_or_create_by(name: value,short_name:value)
        elsif !value.nil? && value != ''
          attribute = DataDictionary.field_from_label(key, year) rescue nil
          dc_attribute = attribute&.downcase&.strip
          if dc_attribute && record.has_attribute?(dc_attribute) && dc_attribute != 'person_id'
            
          
            
            if value == 'Yes'
              record[dc_attribute] = true
            elsif DataDictionary.coded_attribute?(dc_attribute)
              code = DataDictionary.code_from_label(value, dc_attribute)
              
              record[dc_attribute] = code



            else
              
              record[dc_attribute] = value




            end

          
        end
      end
    end

      record.created_by = User.first
      #record.pob = row['Place Of Birth']
      #record.pob_father = row['Place Of Birth - Father']
      #record.pob_mother = row['Place Of Birth - Mother']
      #record.can_speak_english = row['can_speak_english']
      #record.employment = row['employment']



      address = Address.find_or_initialize_by house_number: record.street_house_number,
                                              prefix: record.street_prefix,
                                              name: record.street_name,
                                              suffix: record.street_suffix,
                                              city: record.city,
                                              is_primary: true

      record.building = address.building || Building.create(
        name: address,
        locality: record.locality,
        building_type_ids: [1],
        lat: row['Latitude'],
        lon: row['Longitude'],
        addresses: [address]
      )

      # Not going to sweat if the record doesn't save because this is just for developers to load some census records
      rows_count += 1
      record.save && saved_count += 1
    end

    puts "Managed to load #{saved_count} of #{rows_count} records.\n"
  end
end
