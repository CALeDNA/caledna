# frozen_string_literal: true

class ImportCsvCreateUnmatchedResultJob < ApplicationJob
  include ProcessEdnaResults

  queue_as :default

  def perform(taxonomy_string, result_attributes)
    result_attributes.merge(
      clean_taxonomy_string: remove_na(taxonomy_string),
      normalized: false,
      taxonomy_string: taxonomy_string
    )
    UnmatchedResult.create(result_attributes)
  end
end
