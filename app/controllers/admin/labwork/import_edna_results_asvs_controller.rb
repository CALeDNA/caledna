# frozen_string_literal: true

module Admin
  module Labwork
    class ImportEdnaResultsAsvsController < Admin::ApplicationController
      include ImportCsv::EdnaResultsAsvs

      def index
        authorize 'Labwork::ImportCsv'.to_sym, :index?

        @projects = ResearchProject.order(:name)
                                   .collect { |p| [p.name, p.id] }
        @primers = Primer.order(:name).collect { |p| [p.name, p.id] }
      end

      def create
        authorize 'Labwork::ImportCsv'.to_sym, :create?

        if research_project_id.blank? || primer_id.blank? || file.blank?
          return handle_missing_data_error
        end

        if results.valid?
          handle_success
        else
          handle_error(results)
        end
      end

      private

      def results
        import_csv(file, research_project_id, primer_id)
      end

      def handle_missing_data_error
        flash[:error] = 'You must select a project, primer and file.'
        redirect_to admin_labwork_import_edna_results_asvs_path
      end

      def handle_success
        project = ResearchProject.find(research_project_id)
        primer = Primer.find(primer_id)
        flash[:success] =
          "Importing ASVs for #{project.name}, #{primer.name}..."
        redirect_to admin_labwork_import_csv_status_index_path
      end

      def handle_error(results)
        flash[:error] = results.errors
        redirect_to admin_labwork_import_edna_results_asvs_path
      end

      def research_project_id
        create_params[:research_project_id]
      end

      def primer_id
        create_params[:primer_id]
      end

      def file
        params[:file]
      end

      def create_params
        params.require(:dna_results).permit(
          :research_project_id,
          :primer_id
        )
      end
    end
  end
end
