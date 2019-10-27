# frozen_string_literal: true

module Api
  module V1
    class FieldProjectsController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include PaginatedSamples
      include BatchData

      def show
        render json: {
          samples: SampleSerializer.new(field_project_samples),
          asvs_count: asvs_count
        }, status: :ok
      end
    end
  end
end
