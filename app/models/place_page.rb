# frozen_string_literal: true

class PlacePage < ApplicationRecord
  belongs_to :place

  validates :place, :body, :title, :slug, presence: true
end
