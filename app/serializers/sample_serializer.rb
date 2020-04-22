# frozen_string_literal: true

class SampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :latitude, :longitude, :barcode, :status, :substrate,
             :primers, :gps_precision, :location, :collection_date
end
