# frozen_string_literal: true

module Admin
  module Labwork
    class ImportSamplesController < Admin::ApplicationController
      include ::ImportCsv::SamplesCsv

      def index
        authorize 'Labwork::ImportCsv'.to_sym, :index?

        @projects = FieldProject.all.collect { |p| [p.name, p.id] }
      end

      def create
        authorize 'Labwork::ImportCsv'.to_sym, :create?

        results = import_csv(params[:file], field_project_id)
        if results.valid?
          handle_success
        else
          handle_error(results)
        end
      end

      private

      def handle_success
        project = FieldProject.find(field_project_id)
        flash[:success] =
          "Imported samples for #{project.name}."
        redirect_to admin_root_path
      end

      def handle_error(results)
        flash[:error] = results.errors
        redirect_to admin_labwork_import_samples_path
      end

      def field_project_id
        create_params[:field_project_id]
      end

      def create_params
        params.require(:samples).permit(:field_project_id)
      end
    end
  end
end
