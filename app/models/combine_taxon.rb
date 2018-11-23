# frozen_string_literal: true

class CombineTaxon < ApplicationRecord
  has_many :ncbi_names, foreign_key: 'taxon_id'
end
