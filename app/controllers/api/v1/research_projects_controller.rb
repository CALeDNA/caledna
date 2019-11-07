# frozen_string_literal: true

module Api
  module V1
    class ResearchProjectsController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include BatchData
      include FilterCompletedSamples

      def show
        render json: {
          samples: SampleSerializer.new(research_project_samples),
          asvs_count: asvs_count
        }, status: :ok
      end

      private

      def project
        @project ||= ResearchProject.find_by(slug: params[:id])
      end
    end
  end
end
