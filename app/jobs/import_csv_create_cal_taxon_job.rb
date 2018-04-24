# frozen_string_literal: true

class ImportCsvCreateCalTaxonJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(data)
    create_cal_taxon(data)
  end
end
