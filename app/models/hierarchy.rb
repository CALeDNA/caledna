# frozen_string_literal: true

class Hierarchy < ApplicationRecord
  self.table_name = 'hierarchy'
  belongs_to :taxonomic_unit, foreign_key: 'tsn'
  belongs_to :specimen, foreign_key: 'tsn'

end
