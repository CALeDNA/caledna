# frozen_string_literal: true

class ExtractionType < ApplicationRecord
  has_many :extractions

  def self.default
    ExtractionType.first
  end

  def self.select_options
    ExtractionType.all.map {|e| [e.name, e.id]}
  end
end
