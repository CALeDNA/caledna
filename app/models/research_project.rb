# frozen_string_literal: true

class ResearchProject < ApplicationRecord
  has_many :research_project_extractions, dependent: :destroy
  has_many :extractions, through: :research_project_extractions

  scope :published, -> { where(published: true) }
end
