# frozen_string_literal: true

module Api
  module V1
    class OccurrencesController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include FilterSamples

      def index
        render json: {
          gbif: gbif_occurrences,
          edna: taxa_samples
        }
      end

      private

      def gbif_occurrences_sql
        <<~SQL
          SELECT hexbin.id, count(*) AS count
          FROM pour.hexbin_1km AS hexbin
          JOIN pour.gbif_occurrences
            ON (ST_Contains(hexbin.geom, gbif_occurrences.geom_projected))
          WHERE  scientific_name iLIKE $1
          GROUP BY hexbin.id;
        SQL
      end

      def gbif_occurrences
        @gbif_occurrences ||= begin
          binding = [[nil, "#{params['taxon']}%"]]
          conn.exec_query(gbif_occurrences_sql, 'q', binding)
        end
      end

      def taxa_join_sql
        <<~SQL
          JOIN asvs ON samples_map.id = asvs.sample_id
            AND "samples_map"."status" = 'results_completed'
          JOIN ncbi_nodes_edna as ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
            AND ncbi_nodes.asvs_count > 0
        SQL
      end

      def taxa_samples
        @taxa_samples ||= begin
          website_sample_map
            .select('id', 'barcode', 'latitude', 'longitude')
            .joins(taxa_join_sql)
            .where(published_samples_sql)
            .where('ncbi_nodes.names @> ARRAY[?]', params[:taxon])
            .group('id', 'barcode', 'latitude', 'longitude')
        end
      end

      def grid_level
        0.01
      end

      def radius
        radius = params[:radius].blank? ? 1000 : params[:radius].to_i
        radius = 3000 if radius > 3000
        radius
      end

      def conn
        ActiveRecord::Base.connection
      end
    end
  end
end
