# frozen_string_literal: true

module TaxaSearchHelper
  def self.image(record)
    result = FormatTaxaSearchResult.new(record)
    result.image.try(:url)
  end

  def self.display_common_names(names)
    temp = Class.new { extend CommonNames }
    temp.format_common_names(names)
  end
end
