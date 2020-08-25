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
          sql = <<~SQL
            JOIN sample_primers ON samples_map.id = sample_primers.sample_id
            JOIN primers ON sample_primers.primer_id = primers.id
          SQL
          completed_samples
            .joins(sql)
            .where('samples_map.research_project_ids @> ?', "{#{project_id}}")
            .where('sample_primers.research_project_id = ?', project_id)
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
