# frozen_string_literal: true

module Admin
  module Labwork
    class ImportResultsTaxaController < Admin::ApplicationController
      include ImportCsv::NormalizeTaxonomy

      def index
        authorize 'Labwork::ImportCsv'.to_sym, :index?
      end

      def create
        authorize 'Labwork::ImportCsv'.to_sym, :create?

        results = import_csv(file)
        if results.valid?
          flash[:success] = 'Taxonomies are valid'
          redirect_to admin_labwork_path
        else
          flash[:error] = results.errors
          redirect_to admin_labwork_normalize_taxa_path
        end
      end

      private

      def file
        params[:file]
      end
    end
  end
end
