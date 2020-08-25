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
          base_samples: { data: basic_completed_samples },
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

      def taxa_sql
        <<~SQL
          (ARRAY_AGG(distinct(
            "ncbi_nodes"."canonical_name" || '|' || ncbi_nodes.taxon_id
          )))[0:10] AS taxa
        SQL
      end

      # rubocop:disable Metrics/MethodLength
      def taxa_samples
        @taxa_samples ||= begin
          sql = <<~SQL
            JOIN asvs ON samples_map.id = asvs.sample_id
            JOIN primers ON asvs.primer_id = primers.id
            JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
            AND (ncbi_nodes.iucn_status IS NULL OR
              ncbi_nodes.iucn_status NOT IN
              ('#{IucnStatus::THREATENED.values.join("','")}')
            )
          SQL

          completed_samples
            .select(taxa_sql)
            .joins(sql)
            .where('asvs.taxon_id = ?', params[:id])
            .where('ids @> ?', "{#{params[:id]}}")
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
