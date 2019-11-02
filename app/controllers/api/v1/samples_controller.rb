# frozen_string_literal: true

module Api
  module V1
    class SamplesController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include BatchData

      def index
        render json: {
          samples: SampleSerializer.new(samples),
          asvs_count: asvs_count
        }, status: :ok
      end

      def show
        render json: {
          sample: SampleSerializer.new(sample),
          asvs_count: [sample_asv_count]
        }, status: :ok
      end

      private

      # =======================
      # show
      # =======================

      def sample_asv_count
        count = Asv.where(sample_id: params[:id]).count
        { sample_id: params[:id], count: count }
      end

      def sample
        @sample ||= Sample.approved.with_coordinates.find(params[:id])
      end

      # =======================
      # index
      # =======================

      def samples
        @samples ||= keyword.present? ? multisearch_samples : all_samples
      end

      def all_samples
        @all_samples ||= begin
          samples = Sample.approved.with_coordinates.order(:created_at)
                          .where(query_string)

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

        samples = samples.where('primers && ?', "{#{raw_primers.join(',')}}")
        samples
      end

      def multisearch_ids
        @multisearch_ids ||= begin
          search_results = PgSearch.multisearch(keyword)
          search_results.pluck(:searchable_id)
        end
      end

      def multisearch_samples
        @multisearch_samples ||= all_samples.where(id: multisearch_ids)
      end

      def keyword
        params[:keyword]&.downcase
      end

      # rubocop:disable Metrics/AbcSize
      def query_string
        query = {}
        if params[:status] && params[:status] != 'all'
          query[:status_cd] = params[:status]
        end
        if params[:substrate] && params[:substrate] != 'all'
          query[:substrate_cd] = params[:substrate].split('|')
        end
        query
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
