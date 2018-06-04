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
    iucn_link
    ncbi_link
    wikidata_link
    wikipedia_link
    worms_link
  ].freeze

  has_many :ncbi_names, foreign_key: 'taxon_id'
  has_many :ncbi_citation_nodes
  has_many :ncbi_citations, through: :ncbi_citation_nodes
  belongs_to :ncbi_division, foreign_key: 'cal_division_id'
  has_many :asvs, foreign_key: 'taxonID'
  has_one :external_resource, foreign_key: 'taxon_id'

  # rubocop:disable Lint/AmbiguousOperator
  delegate *LINKS, to: :wikidata_data
  # rubocop:enable Lint/AmbiguousOperator
  delegate :wikidata_entity, :wikidata_image, to: :wikidata_data

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

  def conservation_status
    external_resource&.iucn_status
  end

  def conservation_status?
    conservation_status.present?
  end

  def threatened?
    return false if conservation_status.blank?
    statuses = IucnStatus::THREATENED.values

    statuses.include?(external_resource.iucn_status)
  end

  def image
    wikidata_image || inaturalist_image || eol_image
  end

  # rubocop:disable Metrics/AbcSize
  def wikipedia_link
    return if wikidata_entity.blank?
    results = wikipedia_page

    return if results['entities'].blank?
    return if results['entities'][wikidata_entity]['sitelinks'].blank?

    id = results['entities'][wikidata_entity]['sitelinks']['enwiki']['title']
    @wikipedia_link ||= OpenStruct.new(
      id: id,
      url: "https://en.wikipedia.org/wiki/#{id}",
      text: 'Wikipedia'
    )
  end
  # rubocop:enable Metrics/AbcSize

  def wikipedia_excerpt
    return if wikipedia_link.blank?

    results = WikipediaApi.new.summary(wikipedia_link.id)
    pages = results['query']['pages']
    page_id = pages.keys.first
    return if page_id == -1

    pages[page_id]['extract']
  end

  # rubocop:disable Naming/MethodName
  # no-op methods to match gbif taxonomy
  def taxonomicStatus; end

  # no-op methods to match gbif taxonomy
  def acceptedNameUsageID; end
  # rubocop:enable Naming/MethodName

  def asvs_count
    sql = 'SELECT count(DISTINCT(samples.id)) ' \
    'FROM asvs ' \
    'JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id" '\
    'JOIN extractions ON asvs.extraction_id = extractions.id ' \
    'JOIN samples ON samples.id = extractions.sample_id ' \
    'WHERE samples.missing_coordinates = false ' \
    "AND '{#{taxon_id}}'::text[] <@ lineage[100][1:1];"

    @asvs_count ||= ActiveRecord::Base.connection.execute(sql).first['count']
  end

  private

  def wikidata_api
    @wikidata_api ||= WikidataApi.new
  end

  def wikipedia_page
    @wikipedia_page ||= wikidata_api.wikipedia_page(wikidata_entity)
  end

  def inaturalist_api
    @inaturalist_api ||= ::InaturalistApi.new
  end

  def inaturalist_taxa
    return if inaturalist_link.blank?

    id = inaturalist_link.id
    @inaturalist_taxa ||= begin
      results = inaturalist_api.fetch_taxa(id)
      JSON.parse(results.body)['results'].first
    end
  end

  def inaturalist_image
    return if inaturalist_taxa.blank?

    default_photo = inaturalist_taxa['default_photo']
    return if default_photo.blank?

    OpenStruct.new(
      url: default_photo['medium_url'],
      attribution: default_photo['attribution'],
      source: 'iNaturalist',
      taxa_url: inaturalist_link.url
    )
  end

  def eol_api
    @eol_api ||= ::EolApi.new
  end

  # rubocop:disable Metrics/AbcSize
  def eol_image
    return if eol_image_id.blank?

    media_results = eol_api.fetch_media(eol_image_id)
    return if media_results.response.class == 'Net::HTTPNotFound'

    media = media_results['dataObjects'].first
    OpenStruct.new(
      url: media['eolMediaURL'],
      attribution: media['agents'].first['full_name'],
      source: 'Encyclopedia of Life.',
      taxa_url: eol_link.url
    )
  end
  # rubocop:enable Metrics/AbcSize

  def eol_image_id
    return if eol_link.blank?

    page_results = eol_api.fetch_page(eol_link.id)
    return if page_results.response.class == 'Net::HTTPNotFound'
    return if page_results['dataObjects'].blank?

    page_results['dataObjects'].first['identifier']
  end

  def wikidata_data
    @wikidata_data ||= Wikidata.new(taxon_id, external_resource)
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
