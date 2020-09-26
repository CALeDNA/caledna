# frozen_string_literal: true

class ProcessWikidataDataJob < ApplicationJob
  include WikidataImport

  queue_as :default

  def perform(data)
    process_wikidata_data(data)
  end
end
