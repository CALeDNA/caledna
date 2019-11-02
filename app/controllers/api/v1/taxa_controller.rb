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

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def samples
        @samples ||= begin
          samples =
            Sample.select(:id).select(:barcode).select(:status_cd)
                  .select(:latitude).select(:longitude).select(:substrate_cd)
                  .select(:primers)
                  .joins('JOIN asvs on asvs.sample_id = samples.id')
                  .joins('JOIN ncbi_nodes on ncbi_nodes.taxon_id = ' \
                  'asvs."taxonID"')
                  .results_completed.with_coordinates.order(:created_at)
                  .where(query_string)
                  .where('ids @> ?', "{#{params[:id]}}")
                  .group(:id)

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
