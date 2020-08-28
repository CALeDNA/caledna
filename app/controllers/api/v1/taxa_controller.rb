# frozen_string_literal: true

module Api
  module V1
    class TaxaController < Api::V1::ApplicationController
      include FilterSamples

      def index
        render json: NcbiNodeSerializer.new(taxa).serializable_hash
      end

      def show
        render json: {
          samples: { data: taxa_samples },
          base_samples: { data: taxa_basic_samples },
          taxon: BasicTaxonSerializer.new(taxon)
        }, status: :ok
      end

      def next_taxon_id
        sql = 'SELECT MAX(taxon_id) FROM ncbi_nodes;'
        res = ActiveRecord::Base.connection.exec_query(sql)
        render json: { next_taxon_id: res[0]['max'] + 1 }
      end

      def taxa_search
        render json: {
          data: search_results,
          query: params[:query]
        }
      end

      private

      def conn
        @conn ||= ActiveRecord::Base.connection
      end

      # =======================
      # taxa_search
      # =======================

      # Allows for full-text search of latin canonical_name and
      # english common_names.
      def full_texa_sql
        <<-SQL
        SELECT taxon_id, canonical_name, rank, common_names,
        division_name, count, wiki_excerpt, image
        FROM (
          SELECT taxon_id, canonical_name, rank, common_names,
          ncbi_divisions.name as division_name, asvs_count as count,
          external_resources.wiki_excerpt,
          CASE
            WHEN wikidata_image IS NOT NULL THEN wikidata_image
            WHEN inat_image IS NOT NULL THEN inat_image
            WHEN eol_image IS NOT NULL THEN eol_image
            WHEN gbif_image IS NOT NULL THEN gbif_image
          END image,
          to_tsvector('simple', canonical_name) ||
          to_tsvector('english', coalesce(common_names, '')) AS doc
          FROM ncbi_nodes
          JOIN ncbi_divisions
            ON ncbi_nodes.cal_division_id = ncbi_divisions.id
          LEFT JOIN external_resources
            ON external_resources.ncbi_id = ncbi_nodes.ncbi_id
            AND active = true
          WHERE asvs_count > 0
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

      # Allows for prefix partial search of latin canonical name.
      def prefix_sql
        <<~SQL
          SELECT taxon_id, canonical_name, rank, common_names,
          ncbi_divisions.name as division_name, asvs_count as count,
          external_resources.wiki_excerpt,
          CASE
            WHEN wikidata_image IS NOT NULL THEN wikidata_image
            WHEN inat_image IS NOT NULL THEN inat_image
            WHEN eol_image IS NOT NULL THEN eol_image
            WHEN gbif_image IS NOT NULL THEN gbif_image
          END image
          FROM ncbi_nodes
          JOIN ncbi_divisions
            ON ncbi_nodes.cal_division_id = ncbi_divisions.id
          LEFT JOIN external_resources
            ON external_resources.ncbi_id = ncbi_nodes.ncbi_id
            AND active = true
          WHERE lower(canonical_name) LIKE $1
          AND asvs_count > 0
          ORDER BY asvs_count DESC NULLS LAST
          LIMIT 10
        SQL
      end

      def prefix_results
        @prefix_results ||= begin
          binding = [[nil, "#{query}%"]]
          conn.exec_query(prefix_sql, 'q', binding)
        end
      end

      def full_texa_inat_sql
        <<-SQL
        SELECT taxon_id, canonical_name, rank, common_names,
        division_name, count, wiki_excerpt, image
        FROM (
          SELECT taxon_id, canonical_name, taxon_rank as rank, common_names,
          kingdom as division_name, occurrence_count as count,
          wiki_excerpt,
          CASE
            WHEN wikidata_image IS NOT NULL THEN wikidata_image
            WHEN inat_image IS NOT NULL THEN inat_image
            WHEN eol_image IS NOT NULL THEN eol_image
            WHEN gbif_image IS NOT NULL THEN gbif_image
          END image,
          to_tsvector('simple', canonical_name) ||
          to_tsvector('english', coalesce(common_names, '')) AS doc
          FROM pour.gbif_taxa
          LEFT JOIN external_resources
            ON external_resources.gbif_id = gbif_taxa.taxon_id
            AND active = true
          ORDER BY occurrence_count DESC NULLS LAST
        ) AS search
        WHERE search.doc @@ plainto_tsquery('simple', $1)
        OR search.doc @@ plainto_tsquery('english', $1)
        LIMIT 10
        SQL
      end

      def full_texa_inat_results
        @full_texa_inat_results ||= begin
          binding = [[nil, query]]
          conn.exec_query(full_texa_inat_sql, 'q', binding)
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def full_text_prefix_search
        full_texa_entries = full_texa_results.entries
        prefix_entries = prefix_results.entries
        inat_entries = full_texa_inat_results.entries

        if full_texa_entries.blank? && prefix_entries.blank? &&
           inat_entries.blank?
          []
        elsif full_texa_entries.blank? && inat_entries.blank?
          prefix_entries
        else
          res = (full_texa_entries[0...6] + inat_entries[0...6])
                .sort_by { |entry| entry['count'] }
                .reverse
          res.uniq { |entry| entry['canonical_name'] }[0...10]
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def search_results
        @search_results ||= begin
          return [] if query.blank?
          full_text_prefix_search
        end
      end

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

      def taxa_select_sql
        <<~SQL
          (ARRAY_AGG(
          "ncbi_nodes"."canonical_name" || '|' || ncbi_nodes.taxon_id
          ORDER BY asvs_count_la_river DESC NULLS LAST
          ))[0:15] AS taxa
        SQL
      end

      def taxa_join_sql
        <<~SQL
          JOIN asvs ON samples_map.id = asvs.sample_id
            AND "samples_map"."status" = 'results_completed'
            AND asvs.research_project_id = #{ResearchProject.la_river.id}
          JOIN primers ON asvs.primer_id = primers.id
          JOIN ncbi_nodes_edna as ncbi_nodes
            ON ncbi_nodes.taxon_id = asvs.taxon_id
            AND ncbi_nodes.asvs_count_la_river > 0
        SQL
      end

      def taxa_samples
        @taxa_samples ||= begin
          key = "#{taxon.cache_key}/taxa_samples/#{params_values}"
          Rails.cache.fetch(key) do
            completed_samples
              .select(taxa_select_sql)
              .joins(taxa_join_sql)
              .where('ids @> ?', "{#{params[:id]}}")
              .where('samples_map.field_project_id = ?',
                      FieldProject.la_river.id)
              .load
          end
        end
      end

      def taxa_basic_samples
        @taxa_basic_samples ||= begin
          key = "#{website.cache_key}/taxa_basic_samples/#{params_values}"
          Rails.cache.fetch(key) do
            basic_completed_samples.load
          end
        end
      end

      def website
        @website = Website.default_site
      end

      def params_values
        params.reject { |k, _v| %w[action controller].include?(k) }
              .values.join('_')
      end
    end
  end
end
