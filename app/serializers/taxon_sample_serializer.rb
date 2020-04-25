# frozen_string_literal: true

class TaxonSampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :barcode, :status, :latitude, :longitude, :substrate,
             :gps_precision, :location, :taxa

  attribute :primers do |object|
    object.sample_primers
          .joins(:primer)
          .select('primers.name, primers.id')
          .uniq
  end

  attribute :taxa do |object|
    # HACK: can't access taxa using object.attributes[' as taxa'], so using the
    # this hack of object.attributes.keys.last to access taxa
    taxa_key = object.attributes.keys.last
    object.attributes[taxa_key]
  end
end
