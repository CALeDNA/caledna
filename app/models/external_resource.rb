# frozen_string_literal: true

class ExternalResource < ApplicationRecord
  # http://resolver.globalnames.org/data_sources
  GLOBAL_NAMES_SOURCE_IDS = [12, 11, 180, 3, 163, 174, 4, 9, 1, 2].freeze

  has_one :ncbi_node, foreign_key: 'taxon_id'

  scope :active, -> { where(active: true) }

  scope :missing_links, (lambda do
    where(
      'eol_id IS NULL ' \
      'OR gbif_id IS NULL ' \
      'OR wikidata_image IS NULL ' \
      'OR bold_id IS NULL ' \
      'OR calflora_id IS NULL ' \
      'OR cites_id IS NULL ' \
      'OR cnps_id IS NULL ' \
      'OR gbif_id IS NULL ' \
      'OR inaturalist_id IS NULL ' \
      'OR itis_id IS NULL ' \
      'OR iucn_id IS NULL ' \
      'OR msw_id IS NULL ' \
      'OR wikidata_entity IS NULL ' \
      'OR worms_id IS NULL'
    )
  end)
end
