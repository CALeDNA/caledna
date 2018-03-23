# frozen_string_literal: true

module Admin
  module Labwork
    class NormalizeTaxaController < Admin::ApplicationController
      def index
        @taxa = NormalizeTaxa.where(normalized: false).order(:rank_cd, :taxonomy_string)
      end

      def show
        @normalize_taxon = normalize_taxon
        @new_taxon = Taxon.new
        @suggestions = suggestions
        @more_suggestions = suggestions.present? ? [] : more_suggestions
        @query_suggestions = query_suggestions
      end

      def update
        if normalize_taxon.update(allowed_params.merge(normalized: true))
          redirect_to admin_labwork_normalize_taxa_path
        else
          render 'show'
        end
      end

      def create
        debugger
      end

      private

      def allowed_params
        params.require(:normalize_taxa).permit(:taxonID, :query)
      end

      def normalize_taxon
        @normalize_taxon ||= NormalizeTaxa.find(params[:id])
      end

      def suggestions
        @suggestions ||= Taxon.where(
          canonicalName: normalize_taxon.name,
          taxonRank: normalize_taxon.rank
        ).order(:taxonomicStatus)
      end

      def more_suggestions
        @more_suggestions ||= Taxon.where(
          canonicalName: normalize_taxon.name,
        ).or(Taxon.where(scientificName: normalize_taxon.name))
        .order(:taxonomicStatus)
      end

      def query_suggestions
        @query_suggestions ||= Taxon.where(
          canonicalName: params[:query]
        ).order(:taxonomicStatus)
      end

    end
  end
end
