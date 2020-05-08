# frozen_string_literal: true

class Asv < ApplicationRecord
  belongs_to :research_project
  belongs_to :sample
  belongs_to :primer
  belongs_to :ncbi_node, foreign_key: 'taxon_id'
  has_many :highlights, as: :highlightable

  scope :la_river, (lambda do
    where(research_project_id: ResearchProject::LA_RIVER.try(:id))
  end)
end
