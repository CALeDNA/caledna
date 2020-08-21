# frozen_string_literal: true

module Api
  module V1
    class ResearchProjectsController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include FilterSamples

      def show
        render json: {
          samples: { data: research_project_samples }
        }, status: :ok
      end
    end
  end
end
