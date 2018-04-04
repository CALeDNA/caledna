# frozen_string_literal: true

module Admin
  module Labwork
    class NormalizeTaxaController < Admin::ApplicationController
      def index
        @taxa = CalTaxon.where(normalized: false)
                        .order(:taxonRank, :original_taxonomy)
      end

      def show
        @cal_taxon = cal_taxon
        @new_taxon = Taxon.new
        @suggestions = suggestions
        @more_suggestions = suggestions.present? ? [] : more_suggestions
      end

      def update_existing
        cal_taxon.taxonID = update_existing_params[:taxonID]
        cal_taxon.normalized = true
        if cal_taxon.save(validate: false)
          redirect_to admin_labwork_normalize_taxa_path
        else
          render 'show'
        end
      end

      def update_create
        ActiveRecord::Base.transaction do
          cal_taxon.update!(create_params.merge(normalized: true))
          Taxon.create!(create_params)
        end
        render json: { status: :ok }

      rescue ActiveRecord::RecordInvalid => exception
        render json: {
          status: :unprocessable_entity,
          errors: exception.message.split('Validation failed: ').last.split(', ')
        }
      end

      private

      def update_existing_params
        params.require(:cal_taxon).permit(:taxonID)
      end

      def create_params
        params.require(:normalize_taxon).permit(
          :taxonID,
          :kingdom,
          :phylum,
          :className,
          :order,
          :family,
          :genus,
          :specificEpithet,
          :datasetID,
          :parentNameUsageID,
          :taxonomicStatus,
          :taxonRank,
          :parentNameUsageID,
          :scientificName,
          :canonicalName,
          :genericName,
          hierarchy: %i[
            kingdom phylum class order family genus species
          ]
        )
      end

      def cal_taxon
        id = params[:id] || params[:normalize_taxon_id]
        @cal_taxon ||= CalTaxon.find(id)
      end

      def suggestions
        @suggestions ||= Taxon.where(
          canonicalName: cal_taxon.name,
          taxonRank: cal_taxon.taxonRank
        ).order(:taxonomicStatus)
      end

      def more_suggestions
        @more_suggestions ||= Taxon.where(
          canonicalName: cal_taxon.name
        ).or(Taxon.where(scientificName: cal_taxon.name))
                                   .order(:taxonomicStatus)
      end
    end
  end
end
