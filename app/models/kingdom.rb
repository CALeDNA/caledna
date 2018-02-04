# frozen_string_literal: true

class Kingdom < ApplicationRecord
  has_many :taxonomic_units
  has_many :taxon_unit_types
end
