# frozen_string_literal: true

module Api
  module V1
    class OccurrencesController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include FilterSamples

      def index
        render json: {
          gbif: gbif_occurrences,
          edna: taxa_samples,
          query: params[:taxon]
        }
      end

      private

      def gbif_occurrences_sql
        <<~SQL
          SELECT hexbin.id, count(distinct(gbif_id)) AS count,
            hexbin.latitude, hexbin.longitude
          FROM pour.hexbin_1km AS hexbin
          JOIN pour.gbif_occurrences
            ON (ST_Contains(hexbin.geom_projected, gbif_occurrences.geom_projected))
          JOIN pour.gbif_taxa
            ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
          where gbif_taxa.names @> $1
          GROUP BY hexbin.id;
        SQL
      end

      def gbif_occurrences
        @gbif_occurrences ||= begin
          return [] if params['taxon'].blank?

          binding = [[nil, "{#{params['taxon']}}"]]
          results = conn.exec_query(gbif_occurrences_sql, 'q', binding)

          if results.count.zero?
            binding = [[nil, "#{params['taxon'].downcase}%"]]
            conn.exec_query(gbif_occurrences_common_sql, 'q', binding)
          end
        end
      end


      def full_texa_sql
        <<-SQL
        SELECT taxon_id, canonical_name, rank, common_names,
        division_name
        FROM (
          SELECT taxon_id, canonical_name, rank, common_names,
          ncbi_divisions.name as division_name,
          to_tsvector('simple', canonical_name) ||
          to_tsvector('english', common_names) AS doc
          FROM ncbi_nodes
          JOIN ncbi_divisions
            ON ncbi_nodes.cal_division_id = ncbi_divisions.id
          ORDER BY asvs_count DESC NULLS LAST
        ) AS search
        WHERE search.doc @@ plainto_tsquery('simple', $1)
        OR search.doc @@ plainto_tsquery('english', $1)
        LIMIT 10
        SQL
      end

      def full_texa_results
        @full_texa_results ||= begin
          binding = [[nil, query]]
          conn.exec_query(full_texa_sql, 'q', binding)
        end
      end

      def gbif_occurrences_common_sql
        <<~SQL
          SELECT id, count, latitude, longitude
          FROM (
            SELECT hexbin.id, count(distinct(gbif_id)) AS count,
              hexbin.latitude, hexbin.longitude, vernacular_name,
              to_tsvector('english', vernacular_name) AS doc
            FROM pour.hexbin_1km AS hexbin
            JOIN pour.gbif_occurrences
              ON (ST_Contains(hexbin.geom_projected, gbif_occurrences.geom_projected))
            JOIN pour.gbif_taxa
              ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
            JOIN pour.gbif_common_names
              ON gbif_taxa.taxon_id = gbif_common_names.taxon_id
            GROUP BY hexbin.id, vernacular_name
          ) as search
          WHERE search.doc @@ plainto_tsquery('english', $1);
        SQL
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
