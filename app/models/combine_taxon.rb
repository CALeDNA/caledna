# frozen_string_literal: true

class CombineTaxon < ApplicationRecord
  KINGDOMS = %w[
    Animalia Archaea Bacteria Chromista Fungi Plantae Protozoa
  ].freeze

  has_many :ncbi_names, foreign_key: 'taxon_id'
end
