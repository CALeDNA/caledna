# frozen_string_literal: true

class BasicSampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :latitude, :longitude, :status, :substrate

  attribute :primers do |object|
    object.sample_primers.pluck(:primer_id).uniq
  end
end
