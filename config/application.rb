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

    # customize "sanitize" helper
    # https://github.com/flavorjones/loofah/blob/master/lib/loofah/html5/whitelist.rb

    # https://github.com/rails/rails/blob/master/actionview/lib/action_view/helpers/sanitize_helper.rb
    # To set the default allowed tags or attributes across your application:
    #   config.action_view.sanitized_allowed_tags = ['strong', 'em', 'a']
    #   config.action_view.sanitized_allowed_attributes = ['href', 'title']

    tags = Loofah::HTML5::WhiteList::ACCEPTABLE_ELEMENTS
    config.action_view.sanitized_allowed_tags = tags
  end
end
