# frozen_string_literal: true

class Asv < ApplicationRecord
  belongs_to :taxonomic_unit, foreign_key: :tsn
  belongs_to :extraction
  has_one :hierarchy, foreign_key: :tsn
end
