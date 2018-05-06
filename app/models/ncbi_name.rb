# frozen_string_literal: true

class NcbiName < ApplicationRecord
  belongs_to :ncbi_node, foreign_key: 'taxon_id'
end
