# frozen_string_literal: true

class NcbiNode < ApplicationRecord
  include GlobiService
  include CommonNames

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
  belongs_to :ncbi_division, foreign_key: 'cal_division_id', optional: true
  has_many :asvs, foreign_key: 'taxon_id'
  has_many :external_resources, foreign_key: 'ncbi_id'

  # rubocop:disable Lint/AmbiguousOperator
  delegate *LINKS, to: :format_resources
  # rubocop:enable Lint/AmbiguousOperator
  delegate :wikidata_entity, :wikidata_image, :eol_image, :inat_image,
           :conservation_status, :gbif_id, to: :format_resources

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

  def show_interactions?
    @show_interactions ||= biotic_interactions.values.any?(&:present?)
  end

  def biotic_interactions
    @biotic_interactions ||= display_globi_for(taxon_id)
  end

  def superkingdom
    hierarchy_names['superkingdom']
  end

  def kingdom
    hierarchy_names['kingdom']
  end

  def class_name
    hierarchy_names['class']
  end

  def order
    hierarchy_names['order']
  end

  def family
    hierarchy_names['family']
  end

  def genus
    hierarchy_names['genus']
  end

  def species
    hierarchy_names['species']
  end

  def phylum
    hierarchy_names['phylum']
  end

  # rubocop:disable Metrics/AbcSize
  def taxonomy_string
    if respond_to?(:division_name)
      [division_name, phylum, class_name, order, family, genus, species]
    else
      [superkingdom, kingdom, phylum, class_name, order, family, genus, species]
    end.compact.join(', ')
  end
  # rubocop:enable Metrics/AbcSize

  def synonyms
    @synonyms ||= begin
      NcbiName.where(taxon_id: ncbi_id)
              .where("ncbi_names.name_class IN ('in-part', 'includes', " \
                     "'equivalent name','synonym')")
    end
  end

  def common_names_display(parenthesis: true, truncate: true, first_only: false)
    return if common_names.blank?

    format_common_names(common_names, parenthesis: parenthesis,
                                      truncate: truncate,
                                      first_only: first_only)
  end

  def taxonomy_lineage
    @taxonomy_lineage ||= begin
      taxa = NcbiNode.where('ncbi_id in (?)', ids)
      # NOTE: query returns taxa in random order; use ids.map to order the
      # taxa according according to ids
      ids.map do |id|
        taxa.find { |t| t.taxon_id == id.to_i }
      end
    end
  end

  def conservation_status?
    conservation_status.present?
  end

  def threatened?
    return false if conservation_status.blank?
    statuses = IucnStatus::THREATENED.values

    statuses.include?(conservation_status)
  end

  # loops through external_resources *_image to get saved images and
  # then *_id to get images from api. Best used when showing one taxa.
  def image
    @image ||= begin
      wikidata_image || inat_image || eol_image ||
        inaturalist_api_image || eol_api_image || gbif_api_image
    end
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

  def asvs_count_display
    asvs_count
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
    @inaturalist_taxa ||= begin
      return if inaturalist_link.blank?

      id = inaturalist_link.id
      results = inaturalist_api.fetch_taxa(id)
      JSON.parse(results.body)['results'].first
    end
  end

  def inaturalist_api_image
    @inaturalist_api_image ||= begin
      return if inaturalist_taxa.blank?

      default_photo = inaturalist_taxa['default_photo']
      return if default_photo.blank?

      OpenStruct.new(
        url: default_photo['medium_url'],
        attribution: default_photo['attribution'],
        source: 'iNaturalist'
      )
    end
  end

  def gbif_api
    @gbif_api ||= ::GbifApi.new
  end

  def gbif_occurrences
    @gbif_occurrences ||= begin
      return if gbif_link.blank?

      id = gbif_link.id
      results = gbif_api.occurence_by_taxon(id)
      JSON.parse(results.body)['results']
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def gbif_api_image
    @gbif_api_image ||= begin
      return if gbif_occurrences.blank?

      cc_license = 'http://creativecommons.org/licenses/by-nc/4.0/'
      media = gbif_occurrences.flat_map { |i| i['media'] }
                              .compact
                              .select { |i| i['license'] == cc_license }

      return if media.blank?
      photo = media.first

      OpenStruct.new(
        url: photo['identifier'],
        attribution: "#{photo['creator']} (#{photo['publisher']})",
        source: 'GBIF'
      )
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def eol_api
    @eol_api ||= ::EolApi.new
  end

  def eol_api_image
    @eol_api_image ||= begin
      return if eol_image_obj.blank?

      OpenStruct.new(
        url: eol_image_obj['eolMediaURL'],
        attribution: eol_image_obj['rightsHolder'],
        source: 'Encyclopedia of Life'
      )
    end
  end

  # rubocop:disable Metrics/AbcSize
  def eol_image_obj
    @eol_image_obj ||= begin
      return if eol_link.blank?

      page_results = eol_api.fetch_page(eol_link.id)
      return if page_results.response.class == 'Net::HTTPNotFound'
      response = page_results.parsed_response
      return if response.blank?
      return if response['taxonConcept'].blank?
      return if response['taxonConcept']['dataObjects'].blank?

      response['taxonConcept']['dataObjects'].first
    end
  end
  # rubocop:enable Metrics/AbcSize

  def format_resources
    @format_resources ||=
      FormatExternalResources.new(taxon_id, external_resources)
  end
end
