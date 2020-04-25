# frozen_string_literal: true

class ImportCsvCreateResultRawImportJob < ApplicationJob
  queue_as :default

  def perform(attributes)
    ResultRawImport.create(attributes)
  end
end
