# frozen_string_literal: true

class Primer < ApplicationRecord
  has_many :primer_samples
  has_many :samples, through: :primer_samples
end
