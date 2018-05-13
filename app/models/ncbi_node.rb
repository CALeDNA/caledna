# frozen_string_literal: true

class NcbiNode < ApplicationRecord
  has_many :ncbi_names, foreign_key: 'taxon_id'
  has_many :ncbi_citation_nodes
  has_many :ncbi_citations, through: :ncbi_citation_nodes

  def superkingdom
    rank_name('superkingdom')
  end

  def kingdom
    rank_name('kingdom')
  end

  def className
    rank_name('class')
  end

  def order
    rank_name('order')
  end

  def family
    rank_name('family')
  end

  def genus
    rank_name('genus')
  end

  def species
    rank_name('species')
  end

  def phylum
    rank_name('phylum')
  end

  def taxonRank
    rank
  end

  def canonicalName
    canonical_name
  end

  def taxonomy_string
    [
      superkingdom, kingdom, phylum, className, order, family, genus, species
    ].compact.join(', ')
  end

  def vernaculars
    ::NcbiName.where(name_class: 'common name', taxon_id: taxon_id)
  end

  def image; end

  def taxonomy_tree
    tree = []
    tree.push(name: :superkingdom, value: superkingdom, id: hierarchy['kingdom']) if superkingdom.present?
    tree.push(name: :kingdom, value: kingdom, id: hierarchy['kingdom']) if kingdom.present?
    tree.push(name: :phylum, value: phylum, id: hierarchy['phylum']) if phylum.present?
    tree.push(name: :class, value: className, id: hierarchy['class']) if className.present?
    tree.push(name: :order, value: order, id: hierarchy['order']) if order.present?
    tree.push(name: :family, value: family, id: hierarchy['family']) if family.present?
    tree.push(name: :genus, value: genus, id: hierarchy['genus']) if genus.present?
    tree.push(name: :species, value: species, id: hierarchy['species']) if species.present?
    tree
  end

  def taxa_dataset
    OpenStruct.new(name: 'NCBI', url: 'http://www.ncbi.nlm.nih.gov/')
  end

  def conservation_status; end

  def conservation_status?; end

  def threatened?; end

  def synonyms
    ncbi_names.where(name_class: 'synonym')
  end

  def gbif_link; end

  def inaturalist_link; end

  def eol_link; end

  # no-op methods to match gbif taxonomy
  def taxonomicStatus; end

  # no-op methods to match gbif taxonomy
  def acceptedNameUsageID; end

  private

  def rank_info(rank)
    lineage.select { |l| l.third == rank }.first
  end

  def rank_name(rank)
    rank_info(rank).try(:second)
  end
end
