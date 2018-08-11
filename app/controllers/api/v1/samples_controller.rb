# frozen_string_literal: true

module Api
  module V1
    class SamplesController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include PaginatedSamples
      include BatchData

      def index
        @samples = paginated_samples
        @asvs_count = asvs_count
        render json: {

          samples: SampleSerializer.new(samples),
          asvs_count: asvs_count
        }, status: :ok
      end

      private

      def query_string
        query = {}
        query[:id] = params[:sample_id] if params[:sample_id]
        query
      end
    end
  end
end
