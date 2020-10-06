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
        division_name
        FROM (
          SELECT taxon_id, canonical_name, rank, common_names,
          ncbi_divisions.name as division_name,
          to_tsvector('simple', canonical_name) ||
          to_tsvector('english', coalesce(common_names, '')) AS doc
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

      # Allows for prefix partial search of latin canonical name.
      def prefix_sql
        <<~SQL
          SELECT taxon_id, canonical_name, rank, common_names,
          ncbi_divisions.name as division_name
          FROM ncbi_nodes
          JOIN ncbi_divisions
            ON ncbi_nodes.cal_division_id = ncbi_divisions.id
          WHERE lower(canonical_name) LIKE $1
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

      # NOTE: I want to show a max of ten search results, 6 full text & 4 prefix
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
      def full_text_prefix_search
        full_texa_entries = full_texa_results.entries
        prefix_entries = prefix_results.entries

        if full_texa_entries.blank? && prefix_results.blank?
          []
        elsif full_texa_entries.blank?
          prefix_entries[0...10]
        elsif prefix_results.blank?
          full_texa_entries[0...10]
        elsif full_texa_results.count < 6
          count = 10 - full_texa_results.count
          (full_texa_entries + prefix_entries[0...count])
            .uniq { |res| res['taxon_id'] }
        elsif prefix_results.count < 4
          count = 10 - prefix_results.count
          (full_texa_entries[0...count] + prefix_entries)
            .uniq { |res| res['taxon_id'] }
        else
          (full_texa_entries[0...6] + prefix_entries[0...4])
            .uniq { |res| res['taxon_id'] }
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity

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
          ORDER BY asvs_count DESC NULLS LAST
          ))[0:15] AS taxa
        SQL
      end

      def taxa_join_sql
        <<~SQL
          JOIN asvs ON samples_map.id = asvs.sample_id
            AND "samples_map"."status" = 'results_completed'
          JOIN primers ON asvs.primer_id = primers.id
          JOIN ncbi_nodes_edna as ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
            AND ncbi_nodes.asvs_count > 0
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
