# frozen_string_literal: true

class Asv < ApplicationRecord
  belongs_to :research_project
  belongs_to :sample
  belongs_to :ncbi_node, foreign_key: 'taxon_id'
  has_many :highlights, as: :highlightable
end
