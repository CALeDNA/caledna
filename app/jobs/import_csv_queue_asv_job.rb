# frozen_string_literal: true

class ImportCsvQueueAsvJob < ApplicationJob
  include ImportCsv::EdnaResultsAsvs

  queue_as :default

  def perform(data_json, barcodes, samples_data, asv_attributes)
    queue_asv_job(data_json, barcodes, samples_data, asv_attributes)
  end
end
