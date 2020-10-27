# frozen_string_literal: true

class GbifTaxonTos < ApplicationRecord
  self.table_name = 'external.gbif_taxa_tos'
  self.primary_key = :taxon_id
end
