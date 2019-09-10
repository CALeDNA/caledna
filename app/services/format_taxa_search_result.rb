# frozen_string_literal: true

class FormatTaxaSearchResult
  include SqlParser
  include CommonNames

  attr_reader :records

  def initialize(records)
    @records = records
  end

  # use images saved in exteral_sources. if no images exist and records have
  # inat_ids and eol_ids, connect to eol and inat api.
  def image
    wikidata_image || inaturalist_image || eol_image ||
      inaturalist_api_image || eol_api_image
  end

  def common_names(names, parenthesis: true, truncate: true, first_only: false)
    return if names.blank?

    format_common_names(names, parenthesis: parenthesis, truncate: truncate,
                               first_only: first_only)
  end

  private

  def eol_image
    image = value_for(records.eol_images)
    return if image.blank?
    OpenStruct.new(
      url: image,
      attribution: value_for(records.eol_image_attributions),
      source: 'Encyclopedia of Life'
    )
  end

  def inaturalist_image
    image = value_for(records.inat_images)
    return if image.blank?
    OpenStruct.new(
      url: image,
      attribution: value_for(records.inat_image_attributions),
      source: 'iNaturalist'
    )
  end

  def wikidata_image
    image = value_for(records.wikidata_images)
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
      inat_id = value_for(records.inat_ids)
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
      eol_id = value_for(records.eol_ids)
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
    return if values.blank?

    parse_string_arrays(values).compact.last
  end
end
