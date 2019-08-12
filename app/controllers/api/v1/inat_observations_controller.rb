# frozen_string_literal: true

module Api
  module V1
    class InatObservationsController < Api::V1::ApplicationController
      before_action :add_cors_headers

      def index
        render json: InatObservationSerializer.new(observations),
               status: :ok
      end

      private

      def observations
        if params[:taxon_id]
          resource = ExternalResource.find_by(ncbi_id: params[:taxon_id])
          InatObservation.where(taxon_id: resource.try(:inaturalist_id))
        else
          InatObservation.all
        end
      end
    end
  end
end
