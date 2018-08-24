# frozen_string_literal: true

module Api
  module V1
    class SamplesController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include PaginatedSamples
      include BatchData

      def index
        render json: {
          samples: SampleSerializer.new(samples),
          asvs_count: asvs_count
        }, status: :ok
      end

      def show
        render json: {
          sample: SampleSerializer.new(sample),
          batch_vernaculars: batch_vernaculars,
          asvs_count: [sample_asv_count]
        }, status: :ok
      end

      private

      def sample_asv_count
        count = Asv.where(sample_id: params[:id]).count
        { sample_id: params[:id], count: count }
      end

      def sample
        @sample ||= Sample.approved.with_coordinates.find(params[:id])
      end

      def query_string
        {}
      end
    end
  end
end
