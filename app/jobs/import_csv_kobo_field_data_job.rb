# frozen_string_literal: true

class ImportCsvKoboFieldDataJob < ApplicationJob
  include ImportCsv::KoboFieldData

  queue_as :default

  def perform(data_json, field_project_id)
    kobo_field_data_job(data_json, field_project_id)
  end
end
