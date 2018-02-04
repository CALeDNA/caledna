# frozen_string_literal: true

class Vernacular < ApplicationRecord
  belongs_to :taxonomic_unit, foreign_key: 'tsn'
end
