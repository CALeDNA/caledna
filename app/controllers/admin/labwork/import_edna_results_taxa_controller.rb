# frozen_string_literal: true

module Admin
  module Labwork
    class ImportEdnaResultsTaxaController < Admin::ApplicationController
      include ImportCsv::EdnaResultsTaxa

      def index
        authorize 'Labwork::ImportCsv'.to_sym, :index?
        @projects = ResearchProject.published.order(:name)
                                   .collect { |p| [p.name, p.id] }
        @primers = Primer.all.order(:name).collect(&:name)
      end

      def create
        authorize 'Labwork::ImportCsv'.to_sym, :create?
        results = import_csv(file, research_project_id, primer)
        if results.valid?
          handle_success
        else
          handle_error(results)
        end
      end

      private

      def handle_success
        project = ResearchProject.find(research_project_id)
        flash[:success] =
          "Importing taxonomies for #{project.name}, #{primer}..."
        redirect_to admin_labwork_import_csv_status_index_path
      end

      def handle_error(results)
        flash[:error] = results.errors
        redirect_to admin_labwork_import_edna_results_taxa_path
      end

      def file
        params[:file]
      end

      def research_project_id
        create_params[:research_project_id]
      end

      def primer
        create_params[:primer]
      end

      def create_params
        params.require(:dna_results).permit(
          :research_project_id,
          :primer
        )
      end
    end
  end
end
