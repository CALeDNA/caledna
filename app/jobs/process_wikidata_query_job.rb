# frozen_string_literal: true

class ProcessWikidataQueryJob < ApplicationJob
  include WikidataImport

  queue_as :default

  def perform(data)
    process_query(data)
  end
end
