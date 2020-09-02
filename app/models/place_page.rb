# frozen_string_literal: true

class PlacePage < ApplicationRecord
  belongs_to :place

  validates :place, :body, :title, :slug, presence: true

  scope :published, -> { where(published: true) }
end
