# frozen_string_literal: true

class ImportCsvCreateResultRawImportJob < ApplicationJob
  include ProcessEdnaResults

  queue_as :default

  def perform(row, research_project_id, primer)
    taxonomy_string = row['sum.taxonomy']
    attributes = {
      payload: row,
      research_project_id: research_project_id,
      primer: primer,
      original_taxonomy_string: taxonomy_string,
      clean_taxonomy_string: remove_na(taxonomy_string),
      canonical_name: find_canonical_taxon_from_string(taxonomy_string)
    }
    ResultRawImport.create(attributes)
  end
end
