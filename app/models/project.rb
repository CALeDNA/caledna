# frozen_string_literal: true

class Project < ApplicationRecord
  validates :kobo_id, uniqueness: true
end
