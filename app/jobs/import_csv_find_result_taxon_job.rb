# frozen_string_literal: true

class ImportCsvFindResultTaxonJob < ApplicationJob
  include ImportCsv::EdnaResultsTaxa

  queue_as :default

  def perform(taxonomy_string, asv_attributes)
    find_result_taxon(taxonomy_string, asv_attributes)
  end
end
