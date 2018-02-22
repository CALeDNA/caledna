# frozen_string_literal: true

# require_relative './languages'

class Vernacular < ApplicationRecord
  require 'languages'

  belongs_to :taxon, foreign_key: 'taxonID'
  scope :english, -> { where(language: 'en') }

  def language_name
    return language if language.blank?
    ::Languages::CODES[language.to_sym]
  end
end
