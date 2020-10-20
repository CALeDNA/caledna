# frozen_string_literal: true

class ProcessWikidataMissingLabelJob < ApplicationJob
  include WikidataImport

  queue_as :default

  def perform(data)
    process_wikidata_missing_label(data)
  end
end
