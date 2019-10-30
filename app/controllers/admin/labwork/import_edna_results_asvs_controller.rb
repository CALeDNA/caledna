# frozen_string_literal: true

module Admin
  module Labwork
    class ImportEdnaResultsAsvsController < Admin::ApplicationController
      include ImportCsv::EdnaResultsAsvs

      def index
        authorize 'Labwork::ImportCsv'.to_sym, :index?

        @projects = ResearchProject.all.collect { |p| [p.name, p.id] }
        @extraction_types = ExtractionType.all.collect { |p| [p.name, p.id] }
      end

      def create
        authorize 'Labwork::ImportCsv'.to_sym, :create?

        results =
          import_csv(file, research_project_id, extraction_type_id, primer)
        if results.valid?
          flash[:success] = 'Importing ASVs...'
          redirect_to admin_labwork_import_csv_status_index_path
        else
          handle_error(results)
        end
      end

      private

      def handle_error(results)
        flash[:error] = results.errors
        redirect_to admin_labwork_import_edna_results_asvs_path
      end

      def research_project_id
        create_params[:research_project_id]
      end

      def extraction_type_id
        create_params[:extraction_type_id]
      end

      def primer
        create_params[:primer]
      end

      def file
        params[:file]
      end

      def create_params
        params.require(:dna_results).permit(
          :extraction_type_id,
          :research_project_id,
          :primer
        )
      end
    end
  end
end
