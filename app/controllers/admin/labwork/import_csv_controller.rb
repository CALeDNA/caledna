# frozen_string_literal: true

module Admin
  module Labwork
    class ImportCsvController < Admin::ApplicationController
      include ImportCsv::SampleCsv

      def samples
        @projects = ResearchProject.all.collect { |p| [p.name, p.id] }
      end

      def samples_create
        import_sample_csv(params[:file], research_project_id)
        redirect_to admin_root_path, notice: 'Samples imported.'
      end

      private

      def research_project_id
        create_params[:id]
      end

      def create_params
        params.require(:research_project).permit(:id)
      end
    end
  end
end
