# frozen_string_literal: true

module TaxaSearchHelper
  def self.image(record)
    resource = FetchExternalResources.new(record.taxon_id)

    record.wikidata_image || resource.inaturalist_image || resource.eol_image
  end
end
