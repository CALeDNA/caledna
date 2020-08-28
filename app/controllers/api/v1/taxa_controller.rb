# frozen_string_literal: true

module Api
  module V1
    class TaxaController < Api::V1::ApplicationController
      include FilterSamples

      def index
        render json: NcbiNodeSerializer.new(taxa).serializable_hash
      end

      def show
        render json: {
          samples: { data: taxa_samples },
          base_samples: { data: taxa_basic_samples },
          taxon: BasicTaxonSerializer.new(taxon)
        }, status: :ok
      end

      def next_taxon_id
        sql = 'SELECT MAX(taxon_id) FROM ncbi_nodes;'
        res = ActiveRecord::Base.connection.exec_query(sql)
        render json: { next_taxon_id: res[0]['max'] + 1 }
      end

      private

      # =======================
      # index
      # =======================

      def taxa
        if query.present?
          ::NcbiNode.where('lower("canonical_name") like ?', "#{query}%")
                    .limit(15)
        else
          []
        end
      end

      def query
        params[:query]&.downcase
      end

      # =======================
      # show
      # =======================

      def taxon
        @taxon ||= NcbiNode.find_by(taxon_id: params[:id])
      end

      def taxa_select_sql
        <<~SQL
          (ARRAY_AGG(
          "ncbi_nodes"."canonical_name" || '|' || ncbi_nodes.taxon_id
          ORDER BY asvs_count DESC NULLS LAST
          ))[0:15] AS taxa
        SQL
      end

      def taxa_join_sql
        <<~SQL
          JOIN asvs ON samples_map.id = asvs.sample_id
            AND "samples_map"."status" = 'results_completed'
          JOIN primers ON asvs.primer_id = primers.id
          JOIN ncbi_nodes_edna as ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
            AND ncbi_nodes.asvs_count > 0
        SQL
      end

      # rubocop:disable Metrics/AbcSize
      def taxa_samples
        @taxa_samples ||= begin
          key = "#{taxon.cache_key}/taxa_samples/#{params_values}"
          Rails.cache.fetch(key) do
            completed_samples
              .select(taxa_select_sql)
              .joins(taxa_join_sql)
              .where('ids @> ?', "{#{params[:id]}}")
              .load
          end
        end
      end
      # rubocop:enable Metrics/AbcSize

      def taxa_basic_samples
        @taxa_basic_samples ||= begin
          website = Website.caledna
          key = "#{website.cache_key}/taxa_basic_samples/#{params_values}"
          Rails.cache.fetch(key) do
            basic_completed_samples.load
          end
        end
      end

      def params_values
        params.reject { |k, _v| %w[action controller].include?(k) }
              .values.join('_')
      end
    end
  end
end
