# frozen_string_literal: true

module Admin
  module Labwork
    class ImportKoboSamplesMetadataController < Admin::ApplicationController
      include ::ImportCsv::KoboSamplesMetadata

      def index
        authorize 'Labwork::ImportCsv'.to_sym, :index?
      end

      def create
        authorize 'Labwork::ImportCsv'.to_sym, :create?

        results = import_csv(params[:file])
        if results.valid?
          redirect_to admin_root_path, notice: 'Samples metadata imported.'
        else
          flash[:error] = results.errors
          redirect_to admin_labwork_import_kobo_samples_metadata_path
        end
      end
    end
  end
end
