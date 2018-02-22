# frozen_string_literal: true

class Taxon < ApplicationRecord
  has_many :vernaculars, foreign_key: 'taxonID'
  has_many :asvs, foreign_key: 'taxonID'

  scope :valid, -> { where(taxonomicStatus: 'accepted') }

  def common_name
    names = vernaculars.pluck(:vernacularName)
    "(#{names.join(', ')})" if names.present?
  end

  # rubocop:disable Metrics/LineLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def taxonomy_tree
    tree = []
    tree.push(name: :kingdom, value: kingdom , id: hierarchy['kingdom']) if kingdom.present?;
    tree.push(name: :phylum, value: phylum, id: hierarchy['phylum']) if phylum.present?
    tree.push(name: :class, value: className, id: hierarchy['class']) if className.present?
    tree.push(name: :order, value: order, id: hierarchy['order']) if order.present?
    tree.push(name: :family, value: family, id: hierarchy['family']) if family.present?
    tree.push(name: :genus, value: genus, id: hierarchy['genus']) if genus.present?
    tree.push(name: :species, value: specificEpithet, id: hierarchy['species']) if specificEpithet.present?
    tree.push(name: :subspecies, value: infraspecificEpithet, id: hierarchy['subspecies']) if infraspecificEpithet.present?
    tree
  end
  # rubocop:enable Metrics/LineLength, Metrics/AbcSize,
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
