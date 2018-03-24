# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Caledna
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified
    # here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths += %W[
      #{config.root}/services
      #{config.root}/serializers
    ]

    # NOTE: this allows Administrate to use app helpers
    config.to_prepare do
      Administrate::ApplicationController.helper Caledna::Application.helpers
    end
  end
end
