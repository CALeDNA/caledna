# frozen_string_literal: true

module Api
  module V1
    class SamplesController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include FilterSamples

      def index
        render json: {
          samples: SampleSerializer.new(samples)
        }, status: :ok
      end

      def show
        render json: {
          sample: SampleSerializer.new(sample)
        }, status: :ok
      end

      private

      # =======================
      # show
      # =======================

      def sample
        @sample ||= begin
          Sample.approved
                .left_joins(:asvs)
                .select('COUNT(DISTINCT taxon_id) AS taxa_count')
                .select(FilterSamples.sample_columns)
                .group(:id)
                .find(params[:id])
        end
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
