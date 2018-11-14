# frozen_string_literal: true

class ImportAsvCsvJob < ApplicationJob
  include ImportCsv::TestResultsAsvs

  queue_as :default

  def perform(path, research_project_id, extraction_type_id, primer, delimiter)
    import_asv_csv(path, research_project_id, extraction_type_id, primer,
                   delimiter)
  end
end
