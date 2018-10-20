# frozen_string_literal: true

module Api
  module V1
    class SamplesSearchesController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include PaginatedSamples
      include BatchData

      def show
        render json: {
          samples: SampleSerializer.new(all_samples),
          asvs_count: asvs_count
        }, status: :ok
      end

      private

      def all_samples
        samples = []
        samples += multisearch_samples if multisearch_samples.present?
        samples
      end

      def multisearch_ids
        search_results = PgSearch.multisearch(query)
        search_results.pluck(:searchable_id)
      end

      def multisearch_samples
        @multisearch_samples ||=
          Sample.includes(:field_data_project).approved.with_coordinates
                .where(id: multisearch_ids)
      end

      def query
        params[:query].try(:downcase)
      end

      def query_string
        {}
      end
    end
  end
end
