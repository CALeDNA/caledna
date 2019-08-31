# frozen_string_literal: true

module TaxaSearchHelper
  def self.image(record)
    result = FormatTaxaSearchResult.new(record)
    result.image.try(:url)
  end

  def self.common_names(record)
    result = FormatTaxaSearchResult.new(record)
    return if result.common_names.blank?
    "(#{result.common_names.join(', ')})"
  end
end
