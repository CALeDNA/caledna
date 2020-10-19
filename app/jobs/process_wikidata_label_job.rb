# frozen_string_literal: true

class ProcessWikidataLabelJob < ApplicationJob
  include WikidataImport

  queue_as :default

  def perform(data)
    process_wikidata_label(data)
  end
end
