# frozen_string_literal: true

class ImportCsvUpdateSampleStatusJob < ApplicationJob
  include ImportCsv::EdnaResultsTaxa

  queue_as :default

  def perform(sample_id)
    sample = Sample.find(sample_id)
    sample.status_cd = :results_completed
    sample.save
  end
end
