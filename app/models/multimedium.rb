# frozen_string_literal: true

class Multimedium < ApplicationRecord
  belongs_to :taxon, foreign_key: 'taxonID'

  def image?
    identifier.end_with?('jpg', 'jpeg', 'png')
  end
end
