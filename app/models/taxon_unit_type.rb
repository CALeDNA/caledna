# frozen_string_literal: true

class TaxonUnitType < ApplicationRecord
  belongs_to :kingdom
  has_many :taxonomic_units, foreign_key: 'rank_id'
end
