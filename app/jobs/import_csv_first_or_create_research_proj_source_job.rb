# frozen_string_literal: true

class ImportCsvFirstOrCreateResearchProjSourceJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(sourceable_id, type, research_project_id)
    first_or_create_research_project_source(sourceable_id, type,
                                            research_project_id)
  end
end
