# frozen_string_literal: true

module Admin
  module Labwork
    class ImportProcessingExtractionsController < Admin::ApplicationController
      include ::ImportCsv::ProcessingExtractions

      def index
        authorize 'Labwork::ImportCsv'.to_sym, :index?

        @projects = ResearchProject.all.collect { |p| [p.name, p.id] }
        @extraction_types = ExtractionType.all.collect { |p| [p.name, p.id] }
      end

      def create
        authorize 'Labwork::ImportCsv'.to_sym, :create?

        import_csv(file, research_project_id, extraction_type_id)
        redirect_to admin_root_path, notice: 'Labwork details imported.'
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
        params.require(:extractions).permit(
          :extraction_type_id,
          :research_project_id
        )
      end
    end
  end
end
