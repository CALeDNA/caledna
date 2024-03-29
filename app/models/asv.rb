# frozen_string_literal: true

class Asv < ApplicationRecord
  belongs_to :research_project
  belongs_to :sample
  belongs_to :primer
  belongs_to :ncbi_node, foreign_key: 'taxon_id'

  scope :la_river, (lambda do
    where(research_project_id: ResearchProject.la_river.try(:id))
  end)
end
