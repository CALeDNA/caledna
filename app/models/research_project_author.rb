# frozen_string_literal: true

class ResearchProjectAuthor < ApplicationRecord
  belongs_to :authorable, polymorphic: true
  belongs_to :research_project
end
