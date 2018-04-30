# frozen_string_literal: true

class ImportCsvUpdateExtractionDetailsJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(extraction, extraction_type_id, row)
    # debugger
    update_extraction_details(extraction, extraction_type_id, row)
  end
end
