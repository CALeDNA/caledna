# frozen_string_literal: true

class SampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :latitude, :longitude, :barcode, :status, :substrate,
             :location, :collection_date

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
