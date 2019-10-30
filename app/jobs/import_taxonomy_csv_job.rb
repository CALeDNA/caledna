# frozen_string_literal: true

class ImportTaxonomyCsvJob < ApplicationJob
  include ImportCsv::EdnaResultsTaxa

  queue_as :default

  def perform(path, delimiter)
    import_taxomony_csv(path, delimiter)
  end
end
