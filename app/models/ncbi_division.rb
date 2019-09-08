# frozen_string_literal: true

class NcbiDivision < ApplicationRecord
  SEVEN_KINGDOMS = %w[
    Animalia Plantae Bacteria Fungi Archaea Chromista Protozoa
  ].freeze

  has_many :ncbi_nodes
end
