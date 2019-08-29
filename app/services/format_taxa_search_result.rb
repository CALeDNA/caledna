# frozen_string_literal: true

class FormatTaxaSearchResult
  include SqlParser

  attr_reader :search_result

  def initialize(search_result)
    @search_result = search_result
  end

  def image
    wikidata_image || inaturalist_image || eol_image ||
      inaturalist_api_image || eol_api_image
  end

  private

  def eol_image
    image = value_for(search_result.eol_images)
    return if image.blank?
    OpenStruct.new(
      url: image,
      attribution: value_for(search_result.eol_image_attributions),
      source: 'Encyclopedia of Life'
    )
  end

  def inaturalist_image
    image = value_for(search_result.inat_images)
    return if image.blank?
    OpenStruct.new(
      url: image,
      attribution: value_for(search_result.inat_image_attributions),
      source: 'iNaturalist'
    )
  end

  def wikidata_image
    image = value_for(search_result.wikidata_images)
    return if image.blank?
    OpenStruct.new(
      url: image,
      attribution: 'commons.wikimedia.org',
      source: 'wikimedia'
    )
  end

  def inaturalist_api
    @inaturalist_api ||= ::InaturalistApi.new
  end

  def inaturalist_taxa
    @inaturalist_taxa ||= begin
      inat_id = value_for(search_result.inat_ids)
      return if inat_id.blank?

      results = inaturalist_api.fetch_taxa(inat_id)
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

  def eol_api
    @eol_api ||= ::EolApi.new
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def eol_image_obj
    @eol_image_obj ||= begin
      eol_id = value_for(search_result.eol_ids)
      return if eol_id.blank?

      page_results = eol_api.fetch_page(eol_id)
      return if page_results.response.class == 'Net::HTTPNotFound'
      response = page_results.parsed_response
      return if response.blank?
      return if response['taxonConcept'].blank?
      return if response['taxonConcept']['dataObjects'].blank?

      response['taxonConcept']['dataObjects'].first
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

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

  def value_for(values)
    parse_string_arrays(values).compact.last
  end
end
