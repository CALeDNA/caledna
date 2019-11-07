# frozen_string_literal: true

module Api
  module V1
    class SamplesController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include BatchData
      include FilterSamples

      def index
        render json: {
          samples: SampleSerializer.new(samples),
          asvs_count: asvs_count
        }, status: :ok
      end

      def show
        render json: {
          sample: SampleSerializer.new(sample),
          asvs_count: [sample_asv_count]
        }, status: :ok
      end

      private

      # =======================
      # show
      # =======================

      def sample_asv_count
        count = Asv.where(sample_id: params[:id]).count
        { sample_id: params[:id], count: count }
      end

      def sample
        @sample ||= Sample.approved.with_coordinates.find(params[:id])
      end

      # =======================
      # index
      # =======================

      def samples
        @samples ||= keyword.present? ? multisearch_samples : approved_samples
      end

      def multisearch_ids
        @multisearch_ids ||= begin
          search_results = PgSearch.multisearch(keyword)
          search_results.pluck(:searchable_id)
        end
      end

      def multisearch_samples
        @multisearch_samples ||= approved_samples.where(id: multisearch_ids)
      end

      def keyword
        params[:keyword]&.downcase
      end
    end
  end
end
