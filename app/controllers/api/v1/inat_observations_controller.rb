# frozen_string_literal: true

module Api
  module V1
    class InatObservationsController < Api::V1::ApplicationController
      before_action :add_cors_headers

      def index
        render json: InatObservationSerializer.new(observations)
                                              .serializable_hash,
               status: :ok
      end

      private

      def observations
        if ncbi_id
          observations_by_taxon_id
        else
          InatObservation.all
        end
      end

      def ncbi_id
        params[:taxon_id]
      end

      def observations_by_taxon_id
        resource = ExternalResource.find_by(ncbi_id: ncbi_id)
        inat_id = resource.try(:inaturalist_id)
        return [] if inat_id.blank?

        InatObservation
          .joins('JOIN external.inat_taxa on external.inat_taxa.taxon_id = ' \
          'external.inat_observations.taxon_id')
          .where("ids @> '{?}'", inat_id)
      end
    end
  end
end
