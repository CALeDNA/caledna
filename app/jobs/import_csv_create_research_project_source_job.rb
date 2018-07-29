# frozen_string_literal: true

class ImportCsvCreateResearchProjectSourceJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(sourceable, research_project_id)
    create_research_project_source(sourceable, research_project_id)
  end
end
