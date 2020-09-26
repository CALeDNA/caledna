# frozen_string_literal: true

class UpdateExternalResourceJob < ApplicationJob
  include WikidataImport

  queue_as :default

  def perform(entity, label)
    update_external_resource(entity, label)
  end
end
