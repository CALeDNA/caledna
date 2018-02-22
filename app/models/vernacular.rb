# frozen_string_literal: true

class Vernacular < ApplicationRecord
  belongs_to :taxon, foreign_key: 'taxonID'
end
