# frozen_string_literal: true

module Admin
  module Labwork
    class ImportResultsAsvsController < Admin::ApplicationController
      include ImportCsv::DnaResults

      def index
        authorize 'Labwork::ImportCsv'.to_sym, :index?

        @projects = ResearchProject.all.collect { |p| [p.name, p.id] }
        @extraction_types = ExtractionType.all.collect { |p| [p.name, p.id] }
      end

      def create
        authorize 'Labwork::ImportCsv'.to_sym, :create?

        results =
          import_dna_results(file, research_project_id, extraction_type_id)
        if results.valid?
          flash[:success] = 'DNA results imported'
        else
          flash[:error] = results.errors
        end

        redirect_to admin_root_path
      end

      private

      def research_project_id
        create_params[:research_project_id]
      end

      def extraction_type_id
        create_params[:extraction_type_id]
      end

      def file
        params[:file]
      end

      def create_params
        params.require(:dna_results).permit(
          :extraction_type_id,
          :research_project_id
        )
      end
    end
  end
end
