# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
# require "action_cable/engine"
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require 'csv'

unless ENV['DATABASE_URL']
  require 'dotenv'
  Dotenv.load('.env', ".env.#{Rails.env}")
end


module HistoryForge
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.action_mailer.default_url_options = { host: ENV['BASE_URL'] }

    config.quiet_assets = true

    config.allowed_cors_origins = [
      'http://localhost:4173',
      'http://localhost:3000',
      'http://localhost:3001',
      'http://localhost:5173',
      'http://localhost:5174',
      'https://greenwood.jacrys.com',
      'https://jacrys.com',
      '2600:1702:5f44:3200:18a8:5aff:f2c1:b352'
    ]

    config.active_storage.variant_processor = :vips
    config.active_storage.service = :local

    config.generators.test_framework :rspec
    config.active_record.schema_format = :sql
  end
end
