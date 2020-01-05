# frozen_string_literal: true

class ImportCsvCreateResearchProjectSourceJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(sourceable_id, type, research_project_id)
    create_research_project_source(sourceable_id, type, research_project_id)
  end
end
