# frozen_string_literal: true

class ImportCsvFirstOrCreateAsvJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(asv_attributes)
    first_or_create_asv(asv_attributes)
  end
end
