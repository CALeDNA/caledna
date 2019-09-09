# frozen_string_literal: true

class NcbiDivision < ApplicationRecord
  SEVEN_KINGDOMS = %w[
    Animalia Archaea Bacteria Chromista Fungi Plantae Protozoa
  ].freeze

  has_many :ncbi_nodes
end
