# frozen_string_literal: true

class SampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :latitude, :longitude, :barcode, :status, :substrate,
             :location, :collection_date, :primer_ids, :primer_names,
             :taxa_count
end
