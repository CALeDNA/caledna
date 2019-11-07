# frozen_string_literal: true

module Api
  module V1
    class FieldProjectsController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include BatchData
      include FilterSamples

      def show
        render json: {
          samples: SampleSerializer.new(approved_samples),
          asvs_count: asvs_count
        }, status: :ok
      end

      private

      def query_string
        query = {}
        query[:field_project_id] = params[:id]
        query[:status_cd] = params[:status] if params[:status]
        if params[:substrate]
          query[:substrate_cd] = params[:substrate].split('|')
        end
        query
      end
    end
  end
end
