# frozen_string_literal: true

module Admin
  module Tasks
    class ResearchProjectResultsController < Admin::ApplicationController
      # skip_before_action :verify_authenticity_token

      def index
        authorize 'AdminDashboard'.to_sym, :admin?
        @projects = ResearchProject.order(:name)
                                   .collect { |p| [p.name, p.id] }
      end

      def bulk_delete
        authorize 'AdminDashboard'.to_sym, :admin?
        if project_id.present?
          DeleteResearchProjectResultsJob.perform_later(project_id)
          flash[:success] = 'Research project eDNA results is being deleted...'
          redirect_to admin_research_project_edna_results_path(project_id)
        else
          flash[:error] = 'Must select a research project.'
          redirect_to admin_labwork_bulk_delete_research_project_results_path
        end
      end

      private

      def project_id
        bulk_delete_params['research_project_id']
      end

      def bulk_delete_params
        params.require(:results).permit(:research_project_id)
      end
    end
  end
end
