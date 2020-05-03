# frozen_string_literal: true

module Admin
  module Labwork
    class ImportSamplesResearchMetadataController < Admin::ApplicationController
      include ::ImportCsv::SamplesResearchMetadata

      def index
        authorize 'Labwork::ImportCsv'.to_sym, :index?

        @projects = ResearchProject.order(:name).collect { |p| [p.name, p.id] }
      end

      def create
        authorize 'Labwork::ImportCsv'.to_sym, :create?

        results = import_csv(params[:file], research_project_id)
        if results.valid?
          handle_success
        else
          handle_error(results)
        end
      end

      private

      def handle_success
        project = ResearchProject.find(research_project_id)
        flash[:success] = "Imported samples metadata for #{project.name}."
        redirect_to admin_labwork_import_csv_status_index_path
      end

      def handle_error(results)
        flash[:error] = results.errors
        redirect_to admin_labwork_import_samples_research_metadata_path
      end

      def research_project_id
        create_params[:research_project_id]
      end

      def create_params
        params.require(:samples).permit(:research_project_id)
      end
    end
  end
end
