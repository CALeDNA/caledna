# frozen_string_literal: true

class Project < ApplicationRecord
  include PgSearch
  multisearchable against: [:name]

  validates :kobo_id, uniqueness: true

  has_many :samples
end
