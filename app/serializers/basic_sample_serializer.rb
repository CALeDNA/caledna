# frozen_string_literal: true

class BasicSampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :latitude, :longitude, :status, :substrate

  attribute :primers do |object|
    object.sample_primers
          .joins(:primer)
          .select('primers.name, primers.id')
          .uniq
  end
end
