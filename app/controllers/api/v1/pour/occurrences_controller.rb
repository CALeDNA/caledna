# frozen_string_literal: true

module Api
  module V1
    module Pour
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

        def inat_occurrences
          render json: {
            total_species: total_inat_species,
            total_occurrences: total_inat_occurrences
          }
        end

        private

        # ===================
        # inat_occurrences
        # ===================
        def total_sql(field)
          <<~SQL
            SELECT mapgrid.id, count(distinct(#{field})) AS count,
            mapgrid.latitude, mapgrid.longitude,
            ST_AsGeoJSON(mapgrid.geom) as geom
            FROM pour.gbif_occurrences as gbif_occurrences
             JOIN pour.gbif_taxa
               ON pour.gbif_taxa.taxon_id = gbif_occurrences.taxon_id
             JOIN pour.mapgrid
               ON ST_Contains(mapgrid.geom, gbif_occurrences.geom)
             WHERE mapgrid.size = 2000
             AND mapgrid.type = 'hexagon'
             GROUP BY mapgrid.id;
           SQL
        end

        def total_inat_occurrences
          @total_inat_occurrences ||= begin
            conn.exec_query(total_sql('gbif_occurrences.gbif_id'))
          end
        end

        def total_inat_species
          @total_inat_species ||= begin
            conn.exec_query(total_sql('gbif_taxa.taxon_id'))
          end
        end

        # ===================
        # index: gbif results
        # ===================

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def gbif_occurrences
          @gbif_occurrences ||= begin
            return [] if params['taxon'].blank?

            binding = [[nil, "{#{params['taxon']}}"], [nil, radius],
                       [nil, mapgrid_size]]
            results = conn.exec_query(gbif_occurrences_sql, 'q', binding)

            if results.count.zero? && gbif_common_name.present?
              binding = [[nil, "{#{gbif_common_name}}"], [nil, radius],
                         [nil, mapgrid_size]]
              results =
                conn.exec_query(gbif_occurrences_common_sql, 'q', binding)
            end
            results
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        def gbif_occurences_join_sql
          <<~SQL
            SELECT mapgrid.id, count(distinct(gbif_id)) AS count,
            mapgrid.latitude, mapgrid.longitude, ST_AsGeoJSON(mapgrid.geom) as geom
            FROM pour.gbif_occurrences_river as gbif_occurrences
             JOIN pour.gbif_taxa
               ON pour.gbif_taxa.taxon_id = gbif_occurrences.taxon_id
             JOIN pour.mapgrid
               ON ST_Contains(mapgrid.geom, gbif_occurrences.geom)
           SQL
        end

        def gbif_occurrences_sql
          sql = gbif_occurences_join_sql
          sql += <<~SQL
            WHERE gbif_occurrences.distance = $2
            AND mapgrid.size = $3
            AND mapgrid.type = 'hexagon'
            AND gbif_taxa.names @> $1
            GROUP BY mapgrid.id;
          SQL
          sql
        end

        def gbif_occurrences_common_sql
          sql = gbif_occurences_join_sql
          sql += <<~SQL
            WHERE gbif_occurrences.distance = $2
            AND mapgrid.size = $3
            AND mapgrid.type = 'hexagon'
            AND gbif_taxa.ids @> $1
            GROUP BY mapgrid.id;
          SQL
          sql
        end

        def gbif_common_name_sql
          <<-SQL
            SELECT gbif_taxa.taxon_id
            FROM pour.gbif_common_names
            JOIN pour.gbif_taxa
              ON gbif_taxa.taxon_id = gbif_common_names.taxon_id
            WHERE to_tsvector('english', vernacular_name)
              @@ plainto_tsquery('english', $1)
            ORDER BY occurrence_count DESC NULLS LAST
            LIMIT 1;
          SQL
        end

        def gbif_common_name
          @gbif_common_name ||= begin
            binding = [[nil, params['taxon']]]
            result = conn.exec_query(gbif_common_name_sql, 'q', binding)
            result.entries.first['taxon_id'] if result.entries.present?
          end
        end

        def radius
          radius = params[:radius].blank? ? 1000 : params[:radius].to_i
          radius = 1000 if radius > 3000
          radius
        end

        def mapgrid_size
          1500
        end

        def mapgrid_type
          params[:mapgrid_type].blank? ? :square : :hexagon
        end

        def conn
          ActiveRecord::Base.connection
        end

        # ===================
        # index: edna results
        # ===================

        def ncbi_common_name_sql
          <<-SQL
            SELECT canonical_name
            FROM ncbi_nodes
            WHERE (to_tsvector('simple', canonical_name) ||
              to_tsvector('english', coalesce(common_names, '')))
              @@ plainto_tsquery('english', $1)
            ORDER BY asvs_count DESC NULLS LAST
            LIMIT 1;
          SQL
        end

        def ncbi_common_name
          @ncbi_common_name ||= begin
            binding = [[nil, params['taxon']]]
            result = conn.exec_query(ncbi_common_name_sql, 'q', binding)
            result.entries.first['canonical_name'] if result.entries.present?
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

        def samples(taxon)
          website_sample_map
            .select('id', 'barcode', 'latitude', 'longitude')
            .joins(taxa_join_sql)
            .where(published_samples_sql)
            .where('ncbi_nodes.names @> ARRAY[?]', taxon)
            .group('id', 'barcode', 'latitude', 'longitude')
        end

        def taxa_samples
          @taxa_samples ||= begin
            results = samples(params[:taxon])
            if results.to_a.blank? && ncbi_common_name.present?
              results = samples(ncbi_common_name)
            end
            results
          end
        end
      end
    end
  end
end
