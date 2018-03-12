# frozen_string_literal: true

module Admin
  module Labwork
    class NormalizeTaxaController < Admin::ApplicationController
      def index
        @taxa = NormalizeTaxa.where(normalized: false).order(:rank_cd, :taxonomy_string)
      end

      def show
        @taxon = normalize_taxon
        @suggestions =
          Taxon
          .where(
            canonicalName: normalize_taxon.name,
            taxonRank: normalize_taxon.rank
          )
          .order(:taxonomicStatus)
      end

      def update
        if normalize_taxon.update(allowed_params.merge(normalized: true))
          redirect_to admin_labwork_normalize_taxa_path
        else
          render 'show'
        end
      end

      private

      def allowed_params
        params.require(:normalize_taxa).permit(:taxonID)
      end

      def normalize_taxon
        @normalize_taxon ||= NormalizeTaxa.find(params[:id])
      end
    end
  end
end
