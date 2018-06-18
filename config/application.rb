# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Caledna
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified
    # here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.autoload_paths += %W[
      #{config.root}/services
      #{config.root}/serializers
    ]

    # NOTE: this allows Administrate to use app helpers
    config.to_prepare do
      Administrate::ApplicationController.helper Caledna::Application.helpers
    end

    Raven.configure do |config|
      config.dsn = ENV.fetch('SENTRY_DSN')
    end
  end
end
