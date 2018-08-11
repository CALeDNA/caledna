# frozen_string_literal: true

class SampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :latitude, :longitude, :barcode, :status,
             :field_data_project_id, :field_data_project_name
end
