# frozen_string_literal: true

class FormatTaxaSearchResult
  include SqlParser
  include CommonNames

  attr_reader :records

  def initialize(records)
    @records = records
  end

  # use images saved in exteral_sources.
  def image
    wikidata_image || inaturalist_image || eol_image || gbif_image
  end

  def common_names(names, parenthesis: true, truncate: true, first_only: false)
    return if names.blank?

    format_common_names(names, parenthesis: parenthesis, truncate: truncate,
                               first_only: first_only)
  end

  private

  def gbif_image
    image = value_for(records.gbif_images)
    return if image.blank?
    OpenStruct.new(
      url: image,
      source: 'GBIF'
    )
  end

  def eol_image
    image = value_for(records.eol_images)
    return if image.blank?
    OpenStruct.new(
      url: image,
      source: 'Encyclopedia of Life'
    )
  end

  def inaturalist_image
    image = value_for(records.inat_images)
    return if image.blank?
    OpenStruct.new(
      url: image,
      source: 'iNaturalist'
    )
  end

  def wikidata_image
    image = value_for(records.wikidata_images)
    return if image.blank?
    OpenStruct.new(
      url: image,
      source: 'wikimedia'
    )
  end

  def value_for(values)
    return if values.blank?

    parse_string_arrays(values).compact.last
  end
end
