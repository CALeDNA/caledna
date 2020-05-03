# frozen_string_literal: true

class Website < ApplicationRecord
  DEFAULT_SITE = Website.find_by(name: 'Protecting Our River')

  has_many :pages
  has_many :site_news
end
