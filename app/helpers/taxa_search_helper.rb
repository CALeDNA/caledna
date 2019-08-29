# frozen_string_literal: true

module TaxaSearchHelper
  def self.image(record)
    search_result = FormatTaxaSearchResult.new(record)
    search_result.image.try(:url)
  end
end
