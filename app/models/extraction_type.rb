# frozen_string_literal: true

class ExtractionType < ApplicationRecord
  has_many :extractions

  def self.default
    ExtractionType.first
  end
end
