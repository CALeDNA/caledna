# frozen_string_literal: true

class Primer < ApplicationRecord
  has_many :asvs
  has_many :sample_primers
end
