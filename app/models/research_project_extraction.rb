# frozen_string_literal: true

class ResearchProjectExtraction < ApplicationRecord
  belongs_to :research_project
  belongs_to :extraction
end
