# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class NcbiNode < ApplicationRecord
  LINKS = %i[
    bold_link
    calflora_link
    cites_link
    cnps_link
    eol_link
    gbif_link
    inaturalist_link
    itis_link
    wikipedia_link
    worms_link
  ].freeze

  has_many :ncbi_names, foreign_key: 'taxon_id'
  has_many :ncbi_citation_nodes
  has_many :ncbi_citations, through: :ncbi_citation_nodes
  belongs_to :ncbi_division, foreign_key: 'cal_division_id'
  has_many :asvs, foreign_key: 'taxonID'
  delegate *LINKS, to: :wikidata_data
  delegate :wikidata_entity, to: :wikidata_data

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

  # rubocop:disable Naming/MethodName
  def className
    rank_name('class')
  end
  # rubocop:enable Naming/MethodName

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

  # rubocop:disable Naming/MethodName
  def taxonRank
    rank
  end

  def canonicalName
    canonical_name
  end
  # rubocop:enable Naming/MethodName

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

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/LineLength
  def taxonomy_tree
    tree = []
    tree.push(name: :superkingdom, value: superkingdom, id: hierarchy['superkingdom']) if superkingdom.present?
    tree.push(name: :kingdom, value: kingdom, id: hierarchy['kingdom']) if kingdom.present?
    tree.push(name: :phylum, value: phylum, id: hierarchy['phylum']) if phylum.present?
    tree.push(name: :class, value: className, id: hierarchy['class']) if className.present?
    tree.push(name: :order, value: order, id: hierarchy['order']) if order.present?
    tree.push(name: :family, value: family, id: hierarchy['family']) if family.present?
    tree.push(name: :genus, value: genus, id: hierarchy['genus']) if genus.present?
    tree.push(name: :species, value: species, id: hierarchy['species']) if species.present?
    tree
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/LineLength

  def conservation_status; end

  def conservation_status?; end

  def threatened?; end

  def ncbi_link
    id = taxon_id
    return if id.blank?
    url = 'https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?' \
          'mode=Info&id='
    OpenStruct.new(
      id: id,
      url: "#{url}#{id}&lvl=3",
      text: 'National Center for Biotechnology Information (NCBI)'
    )
  end

  def wikipedia_link
    return if wikidata_entity.blank?
    results = WikidataApi.new.wikipedia_page(wikidata_entity)

    return if results['entities'].blank?
    return if results['entities'][wikidata_entity]['sitelinks'].blank?

    id = results['entities'][wikidata_entity]['sitelinks']['enwiki']['title']
    OpenStruct.new(
      id: id,
      url: "https://en.wikipedia.org/wiki/#{id}",
      text: 'Wikipedia'
    )
  end

  # rubocop:disable Naming/MethodName
  # no-op methods to match gbif taxonomy
  def taxonomicStatus; end

  # no-op methods to match gbif taxonomy
  def acceptedNameUsageID; end
  # rubocop:enable Naming/MethodName


  private

  def wikidata_data
    @wikidata_data ||= Wikidata.new(taxon_id)
  end

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
# rubocop:enable Metrics/ClassLength
