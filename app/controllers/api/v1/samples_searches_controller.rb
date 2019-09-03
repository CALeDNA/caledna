# frozen_string_literal: true

module Api
  module V1
    class SamplesSearchesController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include PaginatedSamples
      include BatchData

      def show
        render json: {
          samples: SampleSerializer.new(search_samples(query)),
          asvs_count: asvs_count
        }, status: :ok
      end

      private

      def query
        params[:query]
      end
    end
  end
end
