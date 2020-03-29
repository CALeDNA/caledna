# frozen_string_literal: true

class ImportCsvCreateResultTaxonJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(data)
    create_result_taxon(data)
  end
end
