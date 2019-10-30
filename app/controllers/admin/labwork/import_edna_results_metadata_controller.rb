# frozen_string_literal: true

module Admin
  module Labwork
    class ImportEdnaResultsMetadataController < Admin::ApplicationController
      include ImportCsv::EdnaResultsMetadata

      def index
        authorize 'Labwork::ImportCsv'.to_sym, :index?

        @projects = ResearchProject.all.collect { |p| [p.name, p.id] }
      end

      def create
        authorize 'Labwork::ImportCsv'.to_sym, :create?

        results =
          import_csv(file, research_project_id)
        if results.valid?
          flash[:success] = 'Importing metadata...'
          redirect_to admin_labwork_path
        else
          handle_error(results)
        end
      end

      private

      def handle_error(results)
        flash[:error] = results.errors
        redirect_to admin_labwork_import_edna_results_metadata_path
      end

      def research_project_id
        create_params[:research_project_id]
      end

      def file
        params[:file]
      end

      def create_params
        params.require(:dna_results).permit(
          :research_project_id
        )
      end
    end
  end
end
