# frozen_string_literal: true

class SiteNews < ApplicationRecord
  belongs_to :website
  has_one_attached :image

  validates :title, presence: true
  validates :body, presence: true

  scope :published, -> { where(published: true) }
  scope :current_site, -> { where(website: Website.default_site) }
end
