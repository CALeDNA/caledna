# frozen_string_literal: true

class GbifOccTaxa < ApplicationRecord
  self.table_name = 'external.gbif_occ_taxa'
  self.primary_key = 'taxonkey'

  has_many :external_resources, foreign_key: 'gbif_id'
end
