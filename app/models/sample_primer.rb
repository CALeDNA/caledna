# frozen_string_literal: true

class SamplePrimer < ApplicationRecord
  belongs_to :research_project
  belongs_to :sample
  belongs_to :primer
end
