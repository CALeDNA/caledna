# frozen_string_literal: true

module Admin
  module Labwork
    class NormalizeNcbiTaxaController < Admin::ApplicationController
      def index
        authorize 'Labwork::NormalizeTaxon'.to_sym, :index?

        @taxa = CalTaxon.where(normalized: false)
                        .order(:taxonRank, :complete_taxonomy)
                        .page params[:page]
      end

      def show
        authorize 'Labwork::NormalizeTaxon'.to_sym, :show?

        @cal_taxon = cal_taxon
        @suggestions = suggestions.present? ? suggestions : more_suggestions
      end

      # NOTE: used when matching test result to existing taxon
      def update_existing
        authorize 'Labwork::NormalizeTaxon'.to_sym, :update?

        cal_taxon.taxonID = update_existing_params[:taxon_id]
        cal_taxon.normalized = true

        if cal_taxon.save(validate: false)
          redirect_to admin_labwork_normalize_ncbi_taxa_path
        else
          render 'show'
        end
      end

      private

      def update_existing_params
        params.require(:cal_taxon).permit(:taxon_id)
      end

      def cal_taxon
        id = params[:id] || params[:normalize_ncbi_taxon_id]
        @cal_taxon ||= CalTaxon.find(id)
      end

      def suggestions
        canonical_name =
          cal_taxon.original_hierarchy[cal_taxon.taxonRank].downcase

        @suggestions ||=
          NcbiNode.where("lower(canonical_name) = '#{canonical_name}'")
      end

      def more_suggestions
        species = cal_taxon.original_taxonomy.split(';').last.downcase
        @more_suggestions ||= NcbiNode.where(
          "lower(REPLACE(canonical_name, '''', '')) = '#{species}'"
        )
      end
    end
  end
end
