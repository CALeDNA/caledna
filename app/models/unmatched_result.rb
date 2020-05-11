# frozen_string_literal: true

class UnmatchedResult < ApplicationRecord
  belongs_to :primer
  belongs_to :research_project
end
