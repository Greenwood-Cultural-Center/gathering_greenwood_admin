# == Schema Information
#
# Table name: person_names
#
#  id              :bigint           not null, primary key
#  person_id       :bigint           not null
#  is_primary      :boolean
#  last_name       :string
#  first_name      :string
#  middle_name     :string
#  name_prefix     :string
#  name_suffix     :string
#  searchable_name :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sortable_name   :string
#
# Indexes
#
#  index_person_names_on_person_id        (person_id)
#  index_person_names_on_searchable_name  (searchable_name) USING gist
#  person_names_primary_name_index        (person_id,is_primary)
#
require 'rails_helper'

RSpec.describe PersonName, type: :model do
  subject { create(:person).names.first }

  describe '#same_name_as?' do
    context 'when the name is indeed the same' do
      it 'returns true' do
        expect(subject).to be_same_name_as(subject)
      end
    end

    context 'when the name is different' do
      let(:other_name) { create(:person).names.first }

      it 'returns false' do
        expect(subject).not_to be_same_name_as(other_name)
      end
    end
  end
end
