# frozen_string_literal: true

class Longname < ApplicationRecord
  belongs_to :taxonomic_unit, foreign_key: 'tsn'
end
