# frozen_string_literal: true

class ImportCsvQueueAsvJob < ApplicationJob
  include ImportCsv::EdnaResultsAsvs

  queue_as :default

  def perform(data_json, research_project_id, extraction_type_id, primer)
    queue_asv_job(data_json, research_project_id, extraction_type_id,
                  primer)
  end
end
