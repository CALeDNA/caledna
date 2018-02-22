# frozen_string_literal: true

class Asv < ApplicationRecord
  belongs_to :extraction
  belongs_to :taxon, foreign_key: 'taxonID'
end
