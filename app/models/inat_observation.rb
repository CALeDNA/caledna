# frozen_string_literal: true

class InatObservation < ApplicationRecord
  self.table_name = 'external.inat_observations'
  self.primary_key = :observation_id

  has_many :research_project_sources, as: :sourceable
  belongs_to :inat_taxon, foreign_key: :taxon_id
end
