# frozen_string_literal: true

module Admin
  module Labwork
    class NormalizeNcbiTaxaController < Admin::ApplicationController
      def index
        authorize 'Labwork::NormalizeTaxon'.to_sym, :index?

        @taxa = ResultTaxon.where(normalized: false)
                           .where(ignore: false)
                           .order(:taxon_rank, :clean_taxonomy_string)
                           .page params[:page]
      end

      def show
        authorize 'Labwork::NormalizeTaxon'.to_sym, :show?

        @result_taxon = result_taxon
        @suggestions = suggestions
      end

      def update_with_suggestion
        authorize 'Labwork::NormalizeTaxon'.to_sym, :update?

        update_result_taxon_with_suggestion

        if result_taxon.save(validate: false)
          redirect_to admin_labwork_normalize_ncbi_taxa_path
        else
          handle_error_id('Could not save the suggeted taxon.')
        end
      end

      def update_with_id
        authorize 'Labwork::NormalizeTaxon'.to_sym, :update?

        taxon = find_taxa_with_source_id
        return handle_error_id('No taxa matches the ID') if taxon.blank?

        update_result_taxon_with_taxon(taxon)

        if result_taxon.save
          redirect_to admin_labwork_normalize_ncbi_taxa_path
        else
          handle_error_id('Could not save taxon ID')
        end
      end

      # rubocop:disable Metrics/MethodLength
      def update_and_create_taxa
        authorize 'Labwork::NormalizeTaxon'.to_sym, :update?
        ActiveRecord::Base.transaction do
          create_or_update_taxa
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

      def ignore_taxon
        authorize 'Labwork::NormalizeTaxon'.to_sym, :update?
        result_taxon.ignore = true
        if result_taxon.save
          redirect_to admin_labwork_normalize_ncbi_taxa_path
        else
          handle_error_id('Could not update results.')
        end
      end

      private

      def update_result_taxon_with_taxon(taxon)
        result_taxon.taxon_id = taxon.taxon_id
        result_taxon.normalized = true
        result_taxon.ncbi_id = taxon.ncbi_id
        result_taxon.bold_id = taxon.bold_id
        result_taxon.ncbi_version_id = taxon.ncbi_version_id
      end

      # ==================
      # update_with_id
      # input: source and source_id
      # find NcbiNode, update ResultTaxa
      # ==================

      def handle_error_id(message)
        flash[:error] = message

        redirect_to admin_labwork_normalize_ncbi_taxon_path(result_taxon)
      end

      def find_taxa_with_source_id
        source = update_with_id_params[:source]
        id = update_with_id_params[:source_id]
        if source == 'NCBI'
          attributes = { ncbi_id: id, source: 'NCBI' }
        elsif source == 'BOLD'
          attributes = { bold_id: id, source: 'BOLD' }
        else
          return
        end
        NcbiNode.find_by(attributes)
      end

      def update_with_id_params
        params.require(:normalize_ncbi_taxon).permit(:source_id, :source)
      end

      # ==================
      # update_with_suggestion
      # input: taxon_id, bold_id, ncbi_id, ncbi_version_id
      # update ResultTaxa
      # ==================

      def update_result_taxon_with_suggestion
        result_taxon.taxon_id = update_with_suggestion_params[:taxon_id]
        result_taxon.bold_id = update_with_suggestion_params[:bold_id]
        result_taxon.ncbi_id = update_with_suggestion_params[:ncbi_id]
        result_taxon.ncbi_version_id =
          update_with_suggestion_params[:ncbi_version_id]
        result_taxon.normalized = true
      end

      def update_with_suggestion_params
        params.require(:normalize_ncbi_taxon).permit(
          :taxon_id,
          :bold_id,
          :ncbi_id,
          :ncbi_version_id
        )
      end

      # ==================
      # update_and_create_taxa
      # input ResultTaxa, parent NcbiNode, new NcbiNode
      # ==================

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def create_or_update_taxa
        ucparams = update_and_create_params

        taxon = NcbiNode.where(rank: ucparams[:rank],
                               canonical_name: ucparams[:canonical_name],
                               source: ucparams[:source])
        if ucparams[:source] == 'NCBI'
          taxon = taxon.where(ncbi_id: ucparams[:ncbi_id])
        elsif ucparams[:source] == 'BOLD'
          taxon = taxon.where(bold_id: ucparams[:bold_id])
        end
        taxon = taxon.first_or_create

        if ['true', true].include?(ucparams['update_result_taxa'])
          update_result_taxon_with_taxon(taxon)
          result_taxon.ncbi_version_id = ucparams['ncbi_version_id']
          result_taxon.save
        end

        taxon.update(create_taxa_params)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def create_taxa_params
        update_and_create_params.except(:result_taxon_id, :update_result_taxa)
      end

      # rubocop:disable Metrics/MethodLength
      def update_and_create_params
        params.require(:normalize_ncbi_taxon).permit(
          :parent_taxon_id,
          :rank,
          :canonical_name,
          :result_taxon_id,
          :division_id,
          :cal_division_id,
          :bold_id,
          :ncbi_id,
          :source,
          :full_taxonomy_string,
          :update_result_taxa,
          :ncbi_version_id,
          hierarchy_names: {},
          hierarchy: {},
          ids: [],
          names: [],
          ranks: []
        )
      end
      # rubocop:enable Metrics/MethodLength

      # ==================
      # show
      # ==================

      def suggestions
        if suggestions_by_canonical_name.present?
          suggestions_by_canonical_name
        elsif suggestions_with_strings.present?
          suggestions_with_strings
        elsif suggestions_by_ncbi_names.present?
          suggestions_by_ncbi_names
        else
          suggestions_by_ncbi_names2017
        end
      end

      def suggestions_by_canonical_name
        @suggestions_by_canonical_name ||= begin
          canonical_name = result_taxon.canonical_name.downcase
          NcbiNode.where('lower(canonical_name) = ?', canonical_name)
        end
      end

      def suggestions_with_strings
        @suggestions_with_strings ||= begin
          canonical_name = result_taxon.canonical_name.downcase
          sql = "lower(REPLACE(canonical_name, '''', '')) = ?"
          NcbiNode.where(sql, canonical_name)
        end
      end

      def name_class
        ['in-part', 'includes', 'scientific name', 'equivalent name', 'synonym']
      end

      def suggestions_by_ncbi_names
        @suggestions_by_ncbi_names ||= begin
          canonical_name = result_taxon.canonical_name
          NcbiNode.joins('JOIN ncbi_names ' \
                         'ON ncbi_names.taxon_id = ncbi_nodes.ncbi_id')
                  .where('ncbi_names.name_class IN (?)', name_class)
                  .where('ncbi_names.name = ?', canonical_name)
        end
      end

      def suggestions_by_ncbi_names2017
        @suggestions_by_ncbi_names2017 ||= begin
          canonical_name = result_taxon.canonical_name
          NcbiNode.joins('JOIN external.ncbi_names_2017 ' \
                         'ON ncbi_names_2017.taxon_id = ncbi_nodes.ncbi_id')
                  .where('ncbi_names_2017.name_class IN (?)', name_class)
                  .where('ncbi_names_2017.name = ?', canonical_name)
        end
      end

      def result_taxon
        @result_taxon ||= begin
          id = params[:id] || params[:normalize_ncbi_taxon_id] ||
               update_and_create_params[:result_taxon_id]

          ResultTaxon.find(id)
        end
      end
    end
  end
end
