# frozen_string_literal: true

class Taxon < ApplicationRecord
  has_many :vernaculars, foreign_key: 'taxonID'
  has_many :asvs, foreign_key: 'taxonID'

  scope :valid, -> { where(taxonomicStatus: 'accepted') }

  def common_name
    names = vernaculars.pluck(:vernacularName)
    "(#{names.join(', ')})" if names.present?
  end

  def taxonomy_tree
    # TODO: re-enable tree
    tree = []
  end
end
