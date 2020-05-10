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
          samples: TaxonSampleSerializer.new(samples),
          base_samples: BasicSampleSerializer.new(completed_samples),
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

      def select_sql
        <<~SQL.chomp
          (array_agg("ncbi_nodes"."canonical_name" || ' | ' ||
          ncbi_nodes.taxon_id))[0:10] AS taxa
        SQL
      end

      def samples
        @samples ||= begin
          completed_samples
            .select(select_sql)
            .joins('JOIN ncbi_nodes on ncbi_nodes.taxon_id = asvs.taxon_id')
            .where('ids @> ?', "{#{params[:id]}}")
            .group(:id)
        end
      end
    end
  end
end
