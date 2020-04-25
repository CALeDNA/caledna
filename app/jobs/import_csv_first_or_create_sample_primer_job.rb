# frozen_string_literal: true

class ImportCsvFirstOrCreateSamplePrimerJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(data)
    first_or_create_sample_primer(data)
  end
end
