# frozen_string_literal: true

module Api
  module V1
    class FieldDataProjectsController < Api::V1::ApplicationController
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

      def query_string
        query = {}
        query[:status_cd] = params[:status] if params[:status]
        query[:field_data_project_id] = params[:id]
        query
      end
    end
  end
end
