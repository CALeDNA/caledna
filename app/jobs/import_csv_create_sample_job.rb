# frozen_string_literal: true

class ImportCsvCreateSampleJob < ApplicationJob
  include ImportCsv::KoboFieldData

  queue_as :default

  def perform(clean_row, field_project_id)
    sample_data = process_sample(clean_row, field_project_id)
    Sample.create(sample_data)
  end
end
