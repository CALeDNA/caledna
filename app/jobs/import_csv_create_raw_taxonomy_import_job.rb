# frozen_string_literal: true

class ImportCsvCreateRawTaxonomyImportJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(taxonomy_string, research_project_id, primer, notes)
    create_raw_taxonomy_import(taxonomy_string, research_project_id, primer,
                               notes)
  end
end
