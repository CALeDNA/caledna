# frozen_string_literal: true

class ImportCsvCreateAsvJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(cell, extraction, taxon)
    create_asv(cell, extraction, taxon)
  end
end
