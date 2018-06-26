# frozen_string_literal: true

require_relative 'production'

Rails.application.configure do
  config.action_mailer.raise_delivery_errors = true
  # https://github.com/lautis/uglifier/issues/127
  config.assets.js_compressor = Uglifier.new(harmony: true)
end
