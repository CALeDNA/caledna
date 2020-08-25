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

      private

      def research_project_samples
        @research_project_samples ||= begin
          completed_samples
            .where('samples_map.research_project_ids @> ?', "{#{project_id}}")
            .where('asvs.research_project_id = ?', project_id)
        end
      end

      def project_id
        @project_id ||= begin
          slug = params[:id] || params[:slug]
          ResearchProject.find_by(slug: slug)&.id
        end
      end
    end
  end
end
