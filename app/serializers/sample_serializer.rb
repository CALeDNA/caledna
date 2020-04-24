# frozen_string_literal: true

class SampleSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :latitude, :longitude, :barcode, :status, :substrate,
             :gps_precision, :location, :collection_date

  attribute :primers do |object, params|
    if params[:research_project_id]
      object.sample_primers
            .where(research_project_id: params[:research_project_id])
            .pluck(:primer_id)
            .uniq
    else
      object.sample_primers.pluck(:primer_id).uniq
    end
  end
end
