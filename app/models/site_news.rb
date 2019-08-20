# frozen_string_literal: true

class SiteNews < ApplicationRecord
  belongs_to :website

  validates :title, presence: true
  validates :body, presence: true

  scope :published, -> { where(published: true) }
  scope :current_site, -> { where(website: Website::DEFAULT_SITE) }
end
