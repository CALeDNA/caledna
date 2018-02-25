# frozen_string_literal: true

class Asv < ApplicationRecord
  belongs_to :extraction
  belongs_to :taxon, foreign_key: 'taxonID', counter_cache: :asvs_count
  has_many :highlights, as: :highlightable
end
