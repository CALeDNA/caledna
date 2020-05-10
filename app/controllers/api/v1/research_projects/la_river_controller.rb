# frozen_string_literal: true

module Api
  module V1
    module ResearchProjects
      class LaRiverController < Api::V1::ApplicationController
        before_action :add_cors_headers
        include FilterSamples
        include AsvTreeFormatter

        def sites
          render json: {
            samples: SampleSerializer.new(samples)
          }, status: :ok
        end

        def area_diversity
          render json: project_service.area_diversity_data, status: :ok
        end

        def pa_area_diversity
          render json: project_service.pa_area_diversity_data, status: :ok
        end

        def sampling_types
          render json: project_service.sampling_types_data, status: :ok
        end

        def detection_frequency
          render json: project_service.detection_frequency, status: :ok
        end

        private

        def samples
          @samples ||= research_project_samples
        end

        def project_service
          ResearchProjectService::LaRiver.new(project, params)
        end

        def project
          @project ||= begin
            ResearchProject.find_by(slug: params[:slug])
          end
        end
      end
    end
  end
end
