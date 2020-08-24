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

      # rubocop:disable Metrics/MethodLength
      def bulk_delete
        authorize 'AdminDashboard'.to_sym, :admin?
        if project_id.present?
          ActiveRecord::Base.transaction do
            delete_records
          end
          flash[:success] = 'Research project eDNA results were deleted.'
          redirect_to admin_research_project_edna_results_path(project_id)
        else
          flash[:error] = 'Must select a research project.'
          redirect_to admin_labwork_bulk_delete_research_project_results_path
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def project_id
        bulk_delete_params['research_project_id']
      end

      def delete_records
        delete_asv
        delete_research_project_sources
        delete_sample_primers
        update_sample_status
      end


      def update_sample_status
        sql = <<~SQL
          UPDATE samples SET status_cd = 'approved' WHERE id IN (
            SELECT id FROM samples WHERE status_cd = 'results_completed'
            EXCEPT
            SELECT  sample_id FROM sample_primers
           );
        SQL

        bindings = [[nil, project_id]]
        execute(sql, 'q', bindings)
      end

      def delete_asv
        sql = 'DELETE FROM asvs WHERE research_project_id = $1;'

        bindings = [[nil, project_id]]
        execute(sql, 'q', bindings)
      end

      def delete_research_project_sources
        sql = 'DELETE FROM research_project_sources WHERE ' \
          'research_project_id = $1'
        bindings = [[nil, project_id]]
        execute(sql, 'q', bindings)
      end

      def delete_sample_primers
        sql = 'DELETE FROM sample_primers WHERE research_project_id = $1;'
        bindings = [[nil, project_id]]
        execute(sql, 'q', bindings)
      end

      def execute(sql, bindings = [])
        ActiveRecord::Base.connection.exec_query(sql, bindings)
      end

      def bulk_delete_params
        params.require(:results).permit(:research_project_id)
      end
    end
  end
end
