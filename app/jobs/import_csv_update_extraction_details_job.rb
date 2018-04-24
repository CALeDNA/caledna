# frozen_string_literal: true

class ImportCsvUpdateExtractionDetailsJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(extraction_type_id, row)
    update_extraction_details(extraction_type_id, row)
  end
end
