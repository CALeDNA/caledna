# frozen_string_literal: true

class NcbiNode < ApplicationRecord
  has_many :ncbi_names, foreign_key: 'taxon_id'
  has_many :ncbi_citation_nodes
  has_many :ncbi_citations, through: :ncbi_citation_nodes
  belongs_to :ncbi_division, foreign_key: 'cal_division_id'
  has_many :asvs, foreign_key: 'taxonID'

  def self.taxa_dataset
    OpenStruct.new(
      name: 'NCBI Taxonomy',
      url: 'https://www.ncbi.nlm.nih.gov/taxonomy',
      citation: 'NCBI Taxonomy database. November 2017.'
    )
  end

  def taxa_dataset
    OpenStruct.new(
      name: 'NCBI Taxonomy',
      url: 'https://www.ncbi.nlm.nih.gov/taxonomy',
      citation: 'NCBI Taxonomy database. November 2017.'
    )
  end

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
    ncbi_names.where(taxon_id: taxon_id)
              .where("name_class = 'common name' OR " \
              "name_class = 'genbank common name'")
  end

  def synonyms
    ncbi_names.where.not(name_class: 'common name')
              .where.not(name_class: 'genbank common name')
  end

  def common_names(parenthesis = true)
    names = vernaculars.pluck(:name).map(&:titleize).uniq
    return if names.blank?

    parenthesis ? "(#{common_names_string(names)})" : common_names_string(names)
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

  def conservation_status; end

  def conservation_status?; end

  def threatened?; end

  def gbif_link; end

  def inaturalist_link; end

  def eol_link; end

  def ncbi_link
    'https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?' \
    "mode=Info&id=#{taxon_id}&lvl=3"
  end

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

  def common_names_string(names)
    max = 3
    names.count > max ? "#{names.take(max).join(', ')}..." : names.join(', ')
  end
end
