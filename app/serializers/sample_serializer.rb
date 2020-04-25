# frozen_string_literal: true

class SampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :latitude, :longitude, :barcode, :status, :substrate,
             :gps_precision, :location, :collection_date

  attribute :primers do |object, params|
    if params[:research_project_id]
      object.sample_primers
            .joins(:primer)
            .where(research_project_id: params[:research_project_id])
            .select('primers.name, primers.id')
            .uniq
    else
      object.sample_primers
            .joins(:primer)
            .select('primers.name, primers.id')
            .uniq
    end
  end
end
