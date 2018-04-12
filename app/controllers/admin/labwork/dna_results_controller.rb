# frozen_string_literal: true

module Admin
  module Labwork
    class DnaResultsController < Admin::ApplicationController
      include ImportCsv::DnaResults
      include ImportCsv::NormalizeTaxonomy

      def taxa; end

      def normalize_taxa
        @missing_taxa = NormalizeTaxa.all
      end

      def taxa_create
        results = normalize_taxonomy(file)
        if results.valid?
          flash[:success] = 'Taxonomies are valid'
          redirect_to admin_labwork_taxa_path
        else
          flash[:error] = results.errors
          redirect_to admin_labwork_normalize_taxa_path
        end
      end

      def asvs
        @projects = ResearchProject.all.collect { |p| [p.name, p.id] }
        @extraction_types = ExtractionType.all.collect { |p| [p.name, p.id] }
      end

      def asvs_create
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
