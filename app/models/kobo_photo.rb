# frozen_string_literal: true

class KoboPhoto < ApplicationRecord
  belongs_to :sample
  has_one_attached :photo
end
