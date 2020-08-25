# frozen_string_literal: true

module Api
  module V1
    class FieldProjectsController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include FilterSamples

      def show
        render json: {
          samples: { data: field_project_samples }
        }, status: :ok
      end

      private

      def field_project_samples
        @field_project_samples ||= begin
          approved_completed_samples.where('field_project_id = ?', params[:id])
        end
      end
    end
  end
end
