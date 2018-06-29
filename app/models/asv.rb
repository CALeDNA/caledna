# frozen_string_literal: true

class Asv < ApplicationRecord
  belongs_to :extraction
  belongs_to :sample
  belongs_to :ncbi_node, foreign_key: 'taxonID'
  has_many :highlights, as: :highlightable
end
