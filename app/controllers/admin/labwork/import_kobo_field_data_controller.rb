# frozen_string_literal: true

module Admin
  module Labwork
    class ImportKoboFieldDataController < Admin::ApplicationController
      include ::ImportCsv::KoboFieldData

      def index
        authorize 'Labwork::ImportCsv'.to_sym, :index?
        @field_projects =
          FieldProject.order(:name).collect { |p| [p.name, p.id] }
      end

      def create
        authorize 'Labwork::ImportCsv'.to_sym, :create?

        results = import_csv(params[:file], create_params[:field_project_id])
        if results.valid?
          handle_success
        else
          flash[:error] = results.errors
          redirect_to admin_labwork_import_kobo_field_data_path
        end
      end

      private

      def handle_success
        project = FieldProject.find(field_project_id)
        flash[:success] = "Imported samples field data for #{project.name}."
        redirect_to admin_root_path
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
