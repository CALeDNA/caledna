# frozen_string_literal: true

module Admin
  module Labwork
    class DnaResultsController < Admin::ApplicationController
      include ImportCsv::DnaResults

      def taxa; end

      def normalize_taxa
        @missing_taxa = NormalizeTaxa.all
      end

      def taxa_create
        results = normalize_taxonomy(params[:file])
        if results.valid?
          flash[:success] = 'Taxonomies are valid'
          redirect_to admin_labwork_taxa_path
        else
          flash[:error] = 'Taxonomies are invalid'
          redirect_to admin_labwork_normalize_taxa_path
        end
      end

      def asvs; end

      def asvs_create
        results = import_dna_results(params[:file])
        if results.valid?
          flash[:success] = 'DNA results imported'
        else
          errors = results.errors.join('; ')
          flash[:error] = errors
        end

        redirect_to admin_labwork_process_extractions_url
      end
    end
  end
end
