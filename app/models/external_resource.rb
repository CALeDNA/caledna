# frozen_string_literal: true

class ExternalResource < ApplicationRecord
  has_one :ncbi_node, foreign_key: 'taxon_id'

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
