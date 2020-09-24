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
          SELECT
          ST_X(ST_SnapToGrid(pour.gbif_occurrences.geom, $3)) AS longitude,
          ST_Y(ST_SnapToGrid(pour.gbif_occurrences.geom, $3)) AS latitude,
          COUNT(DISTINCT(gbif_id))
          FROM pour.gbif_occurrences
          JOIN pour.gbif_taxa ON gbif_occurrences.taxon_id = gbif_taxa.taxon_id
          JOIN places
            ON ST_DWithin(places.geom_projected,
            gbif_occurrences.geom_projected, $1)
          WHERE places.place_source_type_cd = 'LA_river'
          AND places.place_type_cd = 'river'
          AND pour.gbif_taxa.names @> ARRAY[$2]
          GROUP BY ST_SnapToGrid(pour.gbif_occurrences.geom, $3)
        SQL
      end

      def gbif_occurrences
        @gbif_occurrences ||= begin
          binding = [[nil, radius], [nil, params['taxon']], [nil, grid_level]]
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
