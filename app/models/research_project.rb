# frozen_string_literal: true

class ResearchProject < ApplicationRecord
  has_many :research_project_sources
  before_save :set_slug

  scope :published, -> { where(published: true) }

  def extractions
    research_project_sources.where(sourceable_type: 'Extraction')
  end

  private

  def set_slug
    self.slug = name.parameterize.truncate(80, omission: '')
  end
end
