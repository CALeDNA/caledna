# frozen_string_literal: true

class GbifOccurrenceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :latitude, :longitude, :kingdom, :species

  # rubocop:disable Style/SymbolProc
  attribute :lat do |object|
    object.latitude
  end

  attribute :lng do |object|
    object.longitude
  end
  # rubocop:enable Style/SymbolProc
end
