# frozen_string_literal: true

class PpGbifOccTaxa < ApplicationRecord
  self.table_name = 'pillar_point.gbif_occ_taxa'
  self.primary_key = 'taxonkey'

  has_many :external_resources, foreign_key: 'gbif_id'
end
