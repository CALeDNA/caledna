# frozen_string_literal: true

module Api
  module V1
    class LaRiverController < Api::V1::ApplicationController
      before_action :add_cors_headers

      def area_diversity
        render json: area_diversity_json, status: :ok
      end

      def detection_frequency
        render json: project_service.detection_frequency, status: :ok
      end

      private

      def project_service
        ResearchProjectService::LaRiver.new(project, params)
      end

      def area_diversity_json
        project_service.area_diversity_data
      end

      def project
        @project ||= begin
          ResearchProject.find_by(slug: 'los-angeles-river')
        end
      end
    end
  end
end
