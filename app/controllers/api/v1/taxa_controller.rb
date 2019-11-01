# frozen_string_literal: true

module Api
  module V1
    class TaxaController < Api::V1::ApplicationController
      include BatchData

      def index
        render json: NcbiNodeSerializer.new(taxa)
      end

      def show
        render json: {
          samples: SampleSerializer.new(samples),
          asvs_count: asvs_count,
          base_samples: BasicSampleSerializer.new(base_samples)
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

      def cached_taxa_search
        @cached_taxa_search ||= TaxaSearchCache.find_by(taxon_id: params[:id])
      end

      def cached_samples
        @cached_samples ||= Sample.where(id: cached_taxa_search.sample_ids)
      end

      def samples
        @samples ||= cached_taxa_search.present? ? cached_samples : all_samples
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def all_samples
        @all_samples ||= begin
          samples =
            Sample.joins('JOIN asvs on asvs.sample_id = samples.id')
                  .joins('JOIN ncbi_nodes on ncbi_nodes.taxon_id = ' \
                  'asvs."taxonID"')
                  .approved.with_coordinates.order(:barcode)
                  .where(query_string)
                  .where('ids @> ?', "{#{params[:id]}}")

          if params[:primer] && params[:primer] != 'all'
            samples = samples_for_primers(samples)
          end
          samples
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def base_samples
        @base_samples ||= begin
          samples = Sample.results_completed.where(query_string)

          if params[:primer] && params[:primer] != 'all'
            samples = samples_for_primers(samples)
          end
          samples
        end
      end

      def samples_for_primers(samples)
        primers = Primer.all.pluck(:name)
        raw_primers = params[:primer].split('|')
                                     .select { |p| primers.include?(p) }

        samples =
          samples.where('samples.primers && ?', "{#{raw_primers.join(',')}}")
        samples
      end

      def query_string
        query = {}
        if params[:substrate] && params[:substrate] != 'all'
          query[:substrate_cd] = params[:substrate].split('|')
        end
        query
      end
    end
  end
end
