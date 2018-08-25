# frozen_string_literal: true

module Api
  module V1
    class TaxaController < Api::V1::ApplicationController
      include BatchData

      def index
        taxa = ::Taxon.where('lower("canonicalName") like ?', "#{query}%")
                      .limit(10)

        options = {}
        render json: ::TaxonSerializer.new(taxa, options).serialized_json
      end

      def show
        render json: {
          samples: SampleSerializer.new(samples),
          asvs_count: asvs_count,
          base_samples: BasicSampleSerializer.new(Sample.results_completed)
        }, status: :ok
      end

      private

      def query
        params[:query].downcase
      end

      def cached_taxa_search
        @cached_taxa_search ||= TaxaSearchCache.find_by(taxon_id: params[:id])
      end

      def select_sql
        <<-SQL
          SELECT DISTINCT samples.id, samples.barcode, status_cd AS status,
          samples.latitude, samples.longitude
          FROM asvs
          JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id"
          JOIN samples ON samples.id = asvs.sample_id
          WHERE latitude IS NOT NULL AND longitude IS NOT NULL
        SQL
      end

      def raw_samples
        sql = select_sql
        sql += " AND ids @> '{#{conn.quote(params[:id].to_i)}}' "

        raw_records = conn.exec_query(sql)
        raw_records.map { |r| OpenStruct.new(r) }
      end

      def cached_samples
        sql = select_sql
        sql += " AND samples.id in (#{cached_taxa_search.sample_ids.join(', ')}) " \
          'GROUP BY samples.id '

        raw_records = conn.exec_query(sql)
        raw_records.map { |r| OpenStruct.new(r) }
      end

      def samples
        if cached_taxa_search.present?
          cached_samples
        else
          raw_samples
        end
      end

      def conn
        @conn ||= ActiveRecord::Base.connection
      end
    end
  end
end
