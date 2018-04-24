# frozen_string_literal: true

class ImportCsvCreateResearchProjectExtractionJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(extraction, research_project_id)
    create_research_project_extraction(extraction, research_project_id)
  end
end
