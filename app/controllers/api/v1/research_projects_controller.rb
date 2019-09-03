# frozen_string_literal: true

module Api
  module V1
    class ResearchProjectsController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include PaginatedSamples
      include BatchData
      include ResearchProjectService::PillarPointServices::CommonTaxaMap

      def show
        render json: {
          samples: SampleSerializer.new(research_project_samples(project.id)),
          asvs_count: asvs_count
        }, status: :ok
      end

      private

      def project
        ResearchProject.find_by(slug: params[:id])
      end
    end
  end
end
