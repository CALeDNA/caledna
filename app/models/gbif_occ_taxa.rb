# frozen_string_literal: true

class GbifOccTaxa < ApplicationRecord
  self.table_name = 'external.gbif_occ_taxa'
  self.primary_key = 'taxonkey'
end
