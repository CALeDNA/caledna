# frozen_string_literal: true

module Api
  module V1
    class PlacesController < Api::V1::ApplicationController
      before_action :add_cors_headers

      def show
        render json: {
          place: place,
          samples: { data: samples }
        }
      end

      def biodiv
        render json: {
          edna_taxa: edna_taxa,
          edna_occurrences: edna_occurrences,
          gbif_taxa: gbif_taxa,
          gbif_occurrences: gbif_occurrences
        }
      end

      private

      def place_id
        params[:id] || params[:place_id]
      end

      def radius
        radius = params[:radius] || 1000
        conn.quote(radius.to_i)
      end

      def place
        @place ||= begin
          Place
            .select('id', 'name', 'latitude', 'longitude', 'geom', 'count(*)')
            .select("ST_Buffer(places.geom, #{radius}) as buffer")
            .joins('LEFT JOIN samples_map ON ST_DWithin ' \
            '(places.geom::geography, samples_map.geom::geography, 1000)')
            .group('id', 'name', 'latitude', 'longitude', 'geom')
            .find(place_id)
        end
      end

      def samples
        SamplesMap
          .joins('JOIN places ON ST_DWithin ' \
          "(places.geom::geography, samples_map.geom::geography, #{radius})")
          .where('places.id = ?', place_id)
      end

      def edna_basic_sql
        <<~SQL
          FROM samples
          JOIN places
            ON ST_DWithin (places.geom::geography, samples.geom::geography, $1)
          JOIN asvs ON samples.id = asvs.sample_id
          JOIN ncbi_nodes_edna ON ncbi_nodes_edna.taxon_id = asvs.taxon_id
          JOIN ncbi_divisions
            ON ncbi_divisions.id = ncbi_nodes_edna.cal_division_id
          WHERE places.id = $2
          AND research_project_id = #{ResearchProject.la_river.id}
          GROUP BY ncbi_divisions.name
          ORDER BY ncbi_divisions.name
        SQL
      end

      def edna_taxa_sql
        <<~SQL
          SELECT ncbi_divisions.name, COUNT(DISTINCT(asvs.taxon_id))
          #{edna_basic_sql}
        SQL
      end

      def edna_occurrences_sql
        <<~SQL
          SELECT ncbi_divisions.name, COUNT(asvs.taxon_id)
          #{edna_basic_sql}
        SQL
      end

      def edna_taxa
        bindings = [[nil, radius], [nil, place_id]]
        conn.exec_query(edna_taxa_sql, 'q', bindings)
      end

      def edna_occurrences
        bindings = [[nil, radius], [nil, place_id]]
        conn.exec_query(edna_occurrences_sql, 'q', bindings)
      end

      def gbif_basic_sql
        <<~SQL
          FROM places
          JOIN pour.gbif_occurrences
          ON ST_DWithin
            (places.geom::geography, gbif_occurrences.geom::geography, $1)
          JOIN pour.gbif_taxa
            ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
          WHERE places.id = $2
          GROUP BY kingdom
          ORDER BY kingdom;
        SQL
      end

      def gbif_taxa_sql
        <<~SQL
          SELECT pour.gbif_taxa.kingdom,
            COUNT(DISTINCT(gbif_occurrences.taxon_id))
          #{gbif_basic_sql}
        SQL
      end

      def gbif_occurrences_sql
        <<~SQL
          SELECT pour.gbif_taxa.kingdom, COUNT(gbif_occurrences.taxon_id)
          #{gbif_basic_sql}
        SQL
      end

      def gbif_taxa
        bindings = [[nil, radius], [nil, place_id]]
        conn.exec_query(gbif_taxa_sql, 'q', bindings)
      end

      def gbif_occurrences
        bindings = [[nil, radius], [nil, place_id]]
        conn.exec_query(gbif_occurrences_sql, 'q', bindings)
      end

      def conn
        ActiveRecord::Base.connection
      end
    end
  end
end
