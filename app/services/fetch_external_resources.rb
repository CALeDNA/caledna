# frozen_string_literal: true

class FetchExternalResources

  attr_reader :taxon_id, :taxon

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


  # rubocop:disable Lint/AmbiguousOperator
  delegate *LINKS, to: :wikidata_data

  def initialize(taxon_id, taxon = nil)
    @taxon_id = taxon_id
    @taxon = taxon
  end

  def wikidata_data
    @wikidata_data ||= Wikidata.new(taxon_id, external_resource)
  end

  def image
    wikidata_image || inaturalist_image || eol_image
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def eol_image
    return if eol_image_id.blank?

    media_results = eol_api.fetch_media(eol_image_id)
    return if media_results.response.class == 'Net::HTTPNotFound'

    media = media_results['dataObjects'].first
    return if media['eolMediaURL'].blank?

    OpenStruct.new(
      url: media['eolMediaURL'],
      attribution: media['agents'].first['full_name'],
      source: 'Encyclopedia of Life.',
      taxa_url: eol_link.url
    )
    media['eolMediaURL']
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

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

    default_photo['medium_url']
  end

  def eol_api
    @eol_api ||= ::EolApi.new
  end


  private

  def external_resource
    @external_resource ||= ExternalResource.find_by(ncbi_id: taxon_id)
  end

  def wikidata_api
    @wikidata_api ||= WikidataApi.new
  end


  def inaturalist_api
    @inaturalist_api ||= ::InaturalistApi.new
  end



  def eol_image_id
    return if eol_link.blank?

    page_results = eol_api.fetch_page(eol_link.id)
    return if page_results.response.class == 'Net::HTTPNotFound'
    return if page_results['dataObjects'].blank?

    page_results['dataObjects'].first['identifier']
  end
end
