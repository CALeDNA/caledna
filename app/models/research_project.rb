# frozen_string_literal: true

class ResearchProject < ApplicationRecord
  has_many :research_project_sources

  scope :published, -> { where(published: true) }

  def extractions
    research_project_sources.where(sourceable_type: 'Extraction')
  end
end
