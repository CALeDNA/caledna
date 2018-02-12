# frozen_string_literal: true

class FieldDataProject < ApplicationRecord
  validates :kobo_id, uniqueness: true

  has_many :samples, dependent: :destroy
end
