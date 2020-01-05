# frozen_string_literal: true

module Admin
  module Labwork
    class NormalizeNcbiTaxaController < Admin::ApplicationController
      def index
        authorize 'Labwork::NormalizeTaxon'.to_sym, :index?

        @taxa = CalTaxon.where(normalized: false)
                        .where(ignore: false)
                        .order(:taxon_rank, :clean_taxonomy_string)
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

        cal_taxon.taxon_id = update_existing_params[:taxon_id]
        cal_taxon.normalized = true
        cal_taxon.ignore = false

        if cal_taxon.save(validate: false)
          redirect_to admin_labwork_normalize_ncbi_taxa_path
        else
          render 'show'
        end
      end

      # rubocop:disable Metrics/MethodLength
      # NOTE: used when creating new taxon for test results
      def update_create
        authorize 'Labwork::NormalizeTaxon'.to_sym, :update?
        ActiveRecord::Base.transaction do
          cal_taxon.update!(update_cal_taxon_params)
          NcbiNode.create!(create_params)
        end
        render json: { status: :ok }
      rescue ActiveRecord::RecordInvalid => exception
        render json: {
          status: :unprocessable_entity,
          errors: exception.message.split('Validation failed: ').last
                           .split(', ')
        }
      end
      # rubocop:enable Metrics/MethodLength

      private

      def update_existing_params
        params.require(:normalize_ncbi_taxon).permit(:taxon_id)
      end

      def cal_taxon
        id = params[:id] || raw_params[:cal_taxon_id] ||
             params[:normalize_ncbi_taxon_id]
        @cal_taxon ||= CalTaxon.find(id)
      end

      def suggestions
        canonical_name =
          cal_taxon.hierarchy[cal_taxon.taxon_rank].downcase

        @suggestions ||=
          NcbiNode.where("lower(canonical_name) = '#{canonical_name}'")
      end

      def more_suggestions
        species = cal_taxon.original_taxonomy.split(';').last.downcase
        @more_suggestions ||= NcbiNode.where(
          "lower(REPLACE(canonical_name, '''', '')) = '#{species}'"
        )
      end

      def update_cal_taxon_params
        {
          normalized: true,
          ignored: false,
          taxon_id: raw_params[:taxon_id],
          taxon_rank: raw_params[:rank]
        }
      end

      def create_params
        raw_params.except(:cal_taxon_id, :dataset_id)
      end

      # rubocop:disable Metrics/MethodLength
      def raw_params
        params.require(:normalize_ncbi_taxon).permit(
          :taxon_id,
          :parent_taxon_id,
          :rank,
          :canonical_name,
          :cal_taxon_id,
          :division_id,
          :cal_division_id,
          :dataset_id,
          hierarchy_names: {},
          hierarchy: {},
          ids: []
        )
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
