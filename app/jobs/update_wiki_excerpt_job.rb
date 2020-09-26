# frozen_string_literal: true

class UpdateWikiExcerptJob < ApplicationJob
  include WikipediaImport
  queue_as :default

  def perform(resource)
    update_wiki_excerpt(resource)
  end
end
