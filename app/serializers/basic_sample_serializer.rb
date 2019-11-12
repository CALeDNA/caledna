# frozen_string_literal: true

class BasicSampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :latitude, :longitude, :status, :substrate,
             :primers
end
