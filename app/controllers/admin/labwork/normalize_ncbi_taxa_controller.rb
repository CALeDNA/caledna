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
          handle_error_id('Could not save the suggeted taxon.')
        end
      end

      def update_with_id
        authorize 'Labwork::NormalizeTaxon'.to_sym, :update?

        taxon = find_taxa_with_source_id
        return handle_error_id('No taxa matches the ID') if taxon.blank?

        cal_taxon_attr(taxon)
        if cal_taxon.save
          redirect_to admin_labwork_normalize_ncbi_taxa_path
        else
          handle_error_id('Could not save taxon ID')
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

      # ==================
      # update_with_id
      # ==================

      def cal_taxon_attr(taxon)
        cal_taxon.taxon_id = taxon.taxon_id
        cal_taxon.normalized = true
      end

      def handle_error_id(message)
        flash[:error] = message

        redirect_to admin_labwork_normalize_ncbi_taxon_path(cal_taxon)
      end

      def find_taxa_with_source_id
        source = update_with_id_params[:source]
        id = update_with_id_params[:source_id]
        if source == 'NCBI'
          attributes = { ncbi_id: id }
        elsif source == 'BOLD'
          attributes = { bold_id: id }
        else
          return
        end
        NcbiNode.find_by(attributes)
      end

      def update_with_id_params
        params.require(:normalize_ncbi_taxon).permit(:source_id, :source)
      end

      # ==================
      # update_existing
      # ==================

      def update_existing_params
        params.require(:normalize_ncbi_taxon).permit(:taxon_id)
      end

      # ==================
      # update_create
      # ==================

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

      # ==================
      # show
      # ==================

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

      def cal_taxon
        @cal_taxon ||= begin
          id = params[:id] || raw_params[:cal_taxon_id] ||
               params[:normalize_ncbi_taxon_id]
          CalTaxon.find(id)
        end
      end
    end
  end
end
