# frozen_string_literal: true

class ImportCsvCreateAsvJob < ApplicationJob
  include ImportCsv::CreateRecords

  queue_as :default

  def perform(asv_attributes)
    create_asv(asv_attributes)
  end
end
