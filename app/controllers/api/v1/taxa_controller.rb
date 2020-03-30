# frozen_string_literal: true

module Api
  module V1
    class TaxaController < Api::V1::ApplicationController
      include BatchData
      include FilterCompletedSamples

      def index
        render json: NcbiNodeSerializer.new(taxa)
      end

      def show
        render json: {
          samples: TaxonSampleSerializer.new(samples),
          asvs_count: asvs_count,
          base_samples: BasicSampleSerializer.new(completed_samples),
          taxon: BasicTaxonSerializer.new(taxon)
        }, status: :ok
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

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def samples
        @samples ||= begin
          completed_samples
            .select(:id).select(:barcode).select(:status_cd)
            .select(:latitude).select(:longitude).select(:substrate_cd)
            .select(:primers).select(:gps_precision).select(:location)
            .select('array_agg( "ncbi_nodes"."canonical_name"|| ' \
              "' | ' ||ncbi_nodes.taxon_id) AS taxa")
            .joins('JOIN asvs on asvs.sample_id = samples.id')
            .joins('JOIN ncbi_nodes on ncbi_nodes.taxon_id = asvs.taxon_id')
            .where('ids @> ?', "{#{params[:id]}}")
            .group(:id)
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    end
  end
end
