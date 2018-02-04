# frozen_string_literal: true

class TaxonomicUnit < ApplicationRecord
  has_one :hierarchy, foreign_key: 'tsn'
  belongs_to :kingdom
  has_one :longname, foreign_key: 'tsn'
  has_many :vernaculars, foreign_key: 'tsn'
end
