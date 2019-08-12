# frozen_string_literal: true

class InatTaxon < ApplicationRecord
  self.table_name = 'external.inat_taxa'
  self.primary_key = :taxon_id

  has_many :inat_observations, foreign_key: :taxon_id
end
