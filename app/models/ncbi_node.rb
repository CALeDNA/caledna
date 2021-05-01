# frozen_string_literal: true

class NcbiNode < ApplicationRecord
  include GlobiService
  include CommonNames
  include CheckWebsite

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
    wikipedia_link
    worms_link
  ].freeze

  TAXON_RANKS = %w[
    superkingdom kingdom phylum class order family genus species
  ].freeze
  TAXON_RANKS_PHYLUM = %w[phylum class order family genus species].freeze

  has_many :ncbi_names, foreign_key: 'taxon_id'
  has_many :ncbi_citation_nodes
  has_many :ncbi_citations, through: :ncbi_citation_nodes
  belongs_to :ncbi_division, foreign_key: 'cal_division_id', optional: true
  has_many :asvs, foreign_key: 'taxon_id'

  # rubocop:disable Lint/AmbiguousOperator
  delegate *LINKS, to: :format_resources
  # rubocop:enable Lint/AmbiguousOperator
  delegate :wikidata_entity, :wikidata_image, :eol_image, :inat_image,
           :gbif_id, :gbif_image, :wiki_excerpt, :wikipedia_title,
           to: :format_resources

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

  def external_resources
    ExternalResource.where(ncbi_id: ncbi_id)
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
      taxa = NcbiNode.where('taxon_id in (?)', ids)
      # NOTE: query returns taxa in random order; use ids.map to order the
      # taxa according according to ids
      ids.map do |id|
        taxa.find { |t| t.taxon_id == id.to_i }
      end
    end
  end

  def threatened?
    return false if iucn_status.blank?
    statuses = IucnStatus::THREATENED.values

    statuses.include?(iucn_status)
  end

  # loops through external_resources *_image to get saved images and
  # then *_id to get images from api. Best used when showing one taxa.
  # rubocop:disable Metrics/CyclomaticComplexity
  def image
    @image ||= begin
      wikidata_image || inat_image || eol_image || gbif_image ||
        inaturalist_api_image || eol_api_image || gbif_api_image
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # formats the a wikipedia link for a given page title
  def wikipedia_link
    return if wikipedia_title.blank?

    @wikipedia_link ||= OpenStruct.new(
      id: wikipedia_title,
      url: "https://en.wikipedia.org/wiki/#{wikipedia_title}",
      text: 'Wikipedia'
    )
  end

  # connects to wikipedia api to get excerpt for a given title
  def wikipedia_excerpt
    return if wiki_excerpt.blank?
    wiki_excerpt
  end

  def asvs_count_display
    CheckWebsite.caledna_site? ? asvs_count : asvs_count_la_river
  end

  private

  def wikidata_api
    @wikidata_api ||= WikidataApi.new
  end

  # connect to api to get info for a wikipedia page for a given wikidata_entity
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

  # rubocop:disable Metrics/MethodLength
  def inaturalist_api_image
    @inaturalist_api_image ||= begin
      return if inaturalist_taxa.blank?

      default_photo = inaturalist_taxa['default_photo']
      return if default_photo.blank?

      update_external_resource_inat(inaturalist_taxa['id'], default_photo)

      OpenStruct.new(
        url: default_photo['medium_url'],
        attribution: default_photo['attribution'],
        source: 'iNaturalist'
      )
    end
  end
  # rubocop:enable Metrics/MethodLength

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

      media = gbif_occurrences.flat_map { |i| i['media'] }.compact
      return if media.blank?

      photo = media.first
      update_external_resource_gbif(gbif_link.id, photo)

      credit = "#{photo['creator']} (#{photo['publisher']})" if photo['creator']
      OpenStruct.new(
        url: photo['identifier'],
        attribution: credit,
        source: 'GBIF'
      )
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def eol_api
    @eol_api ||= ::EolApi.new
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

  def eol_api_image
    @eol_api_image ||= begin
      return if eol_image_obj.blank?

      update_external_resource_eol(eol_link.id, eol_image_obj)

      OpenStruct.new(
        url: eol_image_obj['eolMediaURL'],
        attribution: eol_image_obj['rightsHolder'],
        source: 'Encyclopedia of Life'
      )
    end
  end

  def format_resources
    @format_resources ||=
      FormatExternalResources.new(ncbi_id, external_resources)
  end

  def update_external_resource_eol(eol_id, photo)
    image = {
      eol_image: photo['eolMediaURL'],
      eol_image_attribution: photo['rightsHolder']
    }
    id = { eol_id: eol_id }
    update_resource(image, id)
  end

  def update_external_resource_inat(inaturalist_id, photo)
    image = {
      inat_image: photo['medium_url'],
      inat_image_attribution: photo['attribution'],
      inat_image_id: photo['id']
    }
    id = { inaturalist_id: inaturalist_id }
    update_resource(image, id)
  end

  # rubocop:disable Metrics/MethodLength
  def update_external_resource_gbif(gbif_id, photo)
    credit = if photo['creator'].present?
               "#{photo['creator']} (#{photo['publisher']})"
             else
               photo['rightsHolder']
             end
    image = {
      gbif_image: photo['identifier'],
      gbif_image_attribution: credit
    }
    id = { gbif_id: gbif_id }
    update_resource(image, id)
  end
  # rubocop:enable Metrics/MethodLength

  def update_resource(image, id)
    resource = ExternalResource.where(ncbi_id: ncbi_id, active: true).where(id)
    resource.update(image) if resource.present?
  end
end
