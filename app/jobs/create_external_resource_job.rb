# frozen_string_literal: true

class CreateExternalResourceJob < ApplicationJob
  include WikidataImport

  queue_as :default

  rescue_from(ActiveRecord::RecordNotUnique) do |_|
  end

  def perform(data)
    create_external_resource(data)
  end
end
