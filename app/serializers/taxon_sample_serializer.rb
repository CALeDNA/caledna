# frozen_string_literal: true

class TaxonSampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :barcode, :status_cd, :latitude, :longitude, :substrate_cd,
             :location, :primer_ids, :primer_names, :taxa_count

  attribute :taxa do |object|
    object.taxa if object.attributes.include?('taxa')
  end
end
