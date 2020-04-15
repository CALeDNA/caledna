# frozen_string_literal: true

class ImportCsvUpdateOrCreateResultTaxonJob < ApplicationJob
  include ImportCsv::EdnaResultsTaxa

  queue_as :default

  def perform(taxonomy_string, asv_attributes)
    update_or_create_result_taxon(taxonomy_string, asv_attributes)
  end
end
