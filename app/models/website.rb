# frozen_string_literal: true

class Website < ApplicationRecord
  DEFAULT_SITE = 'Protecting Our River'
  has_many :pages
  has_many :site_news

  scope :default_site, -> { find_by(name: DEFAULT_SITE) }
  scope :caledna, -> { find_by(name: 'CALeDNA') }
  scope :la_river, -> { find_by(name: 'Protecting Our River') }
end
