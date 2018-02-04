class Specimen < ApplicationRecord
  self.table_name = 'specimens'

  belongs_to :taxonomic_unit, foreign_key: :tsn
  belongs_to :sample
end
