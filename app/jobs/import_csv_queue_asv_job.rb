# frozen_string_literal: true

class ImportCsvQueueAsvJob < ApplicationJob
  include ImportCsv::EdnaResultsAsvs

  queue_as :default

  def perform(data, sample_cells, extractions, primer)
    queue_asv_job(data, sample_cells, extractions, primer)
  end
end
