# frozen_string_literal: true

# require_relative './languages'

class Vernacular < ApplicationRecord
  require 'languages'

  self.table_name = 'external.gbif_vernaculars'

  belongs_to :taxon, foreign_key: 'taxonID'
  scope :english, -> { where(language: 'en') }

  def language_name
    return language if language.blank?
    ::Languages::CODES[language.to_sym]
  end
end
