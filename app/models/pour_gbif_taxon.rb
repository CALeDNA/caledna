# frozen_string_literal: true

class PourGbifTaxon < ApplicationRecord
  self.table_name = 'pour.gbif_taxa'
  self.primary_key = :taxon_id
end
