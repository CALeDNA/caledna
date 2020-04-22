# frozen_string_literal: true

class ImportCsvCreateSamplePrimerJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(data)
    create_sample_primer(data)
  end
end
