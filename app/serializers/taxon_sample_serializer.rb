# frozen_string_literal: true

class TaxonSampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :barcode, :status, :latitude, :longitude, :substrate,
             :location

  attribute :taxa do |object|
    object.taxa if object.attributes.include?('taxa')
  end

  attribute :primer_ids do |object|
    object.primer_ids if object.attributes.include?('primer_ids')
  end

  attribute :primer_names do |object|
    object.primer_names if object.attributes.include?('primer_names')
  end

  attribute :taxa_count do |object|
    object.taxa_count if object.attributes.include?('taxa_count')
  end
end
