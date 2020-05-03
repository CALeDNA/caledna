# frozen_string_literal: true

class ImportCsvCreateOrUpdateResearchProjSourceJob < ApplicationJob
  include ImportCsv::SamplesResearchMetadata

  queue_as :default

  def perform(row, barcode, research_project_id)
    create_or_update_research_proj_source(row, barcode, research_project_id)
  end
end
