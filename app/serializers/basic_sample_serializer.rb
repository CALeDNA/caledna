# frozen_string_literal: true

class BasicSampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :latitude, :longitude, :status, :substrate

  attribute :primer_ids do |object|
    object.primer_ids if object.attributes.include?('primer_ids')
  end
end
