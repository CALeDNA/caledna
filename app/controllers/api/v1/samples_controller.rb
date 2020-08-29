# frozen_string_literal: true

module Api
  module V1
    class SamplesController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include FilterSamples
      include AsvTreeFormatter

      def index
        render json: {
          samples: { data: samples }
        }, status: :ok
      end

      def show
        render json: {
          sample: { data: sample }
        }, status: :ok
      end

      def taxa_list
        render json: {
          taxa_list: organisms
        }, status: :ok
      end

      def taxa_tree
        render json: {
          taxa_tree: asv_tree_taxa
        }, status: :ok
      end

      private

      # =======================
      # show
      # =======================

      def sample_join_sql
        <<~SQL
          LEFT JOIN research_project_sources  as rps
          ON rps.sourceable_id = samples.id
          AND sourceable_type = 'Sample'
          LEFT JOIN research_projects
          ON research_projects.id = rps.research_project_id
          AND research_projects.published = true
        SQL
      end

      def sample
        @sample ||= begin
          approved_completed_samples.find_by(id: sample_id)
        end
      end

      def sample_id
        params[:id] || params[:sample_id]
      end

      def asv_tree_taxa
        @asv_tree_taxa ||= fetch_asv_tree_for_sample(sample.id)
      end

      # rubocop:disable Metrics/MethodLength
      def organisms_sql
        sql = <<~SQL
          SELECT
          ncbi_divisions.name AS division_name,
          (hierarchy_names ->>'phylum')::text ||'|'||
            (hierarchy ->>'phylum')::text as phylum,
          (hierarchy_names ->>'class')::text ||'|'||
            (hierarchy ->>'class')::text as class,
          (hierarchy_names ->>'order')::text ||'|'||
            (hierarchy ->>'order')::text as order,
          (hierarchy_names ->>'family')::text ||'|'||
            (hierarchy ->>'family')::text as family,
          (hierarchy_names ->>'genus')::text ||'|'||
            (hierarchy ->>'genus')::text as genus,
          (hierarchy_names ->>'species')::text ||'|'||
            (hierarchy ->>'species')::text as species,
          ncbi_nodes.taxon_id, ncbi_nodes.iucn_status,
          rank,
          common_names
          FROM ncbi_nodes
          JOIN asvs ON asvs.taxon_id = ncbi_nodes.taxon_id
          JOIN ncbi_divisions
            ON ncbi_nodes.cal_division_id = ncbi_divisions.id
          WHERE asvs.sample_id = $1
        SQL

        if CheckWebsite.pour_site?
          sql += "AND research_project_id = #{ResearchProject.la_river.id}"
        end

        sql + <<~SQL
          GROUP BY ncbi_nodes.taxon_id, ncbi_nodes.iucn_status,
          ncbi_divisions.name
          ORDER BY division_name,
          hierarchy_names ->>'phylum',
          hierarchy_names ->>'class',
          hierarchy_names ->>'order',
          hierarchy_names ->>'family',
          hierarchy_names ->>'genus',
          hierarchy_names ->>'species';
        SQL
      end
      # rubocop:enable Metrics/MethodLength

      def organisms
        @organisms ||= begin
          binding = [[nil, params[:sample_id]]]
          conn.exec_query(organisms_sql, 'q', binding)
        end
      end

      # =======================
      # index
      # =======================

      def samples
        @samples ||= begin
          keyword.present? ? multisearch_samples : cached_samples
        end
      end

      def cached_samples
        key = "#{website.cache_key}/api_samples/#{params_values}"
        Rails.cache.fetch(key) do
          approved_completed_samples.load
        end
      end

      def multisearch_ids
        @multisearch_ids ||= begin
          search_results = PgSearch.multisearch(keyword)
          search_results.pluck(:searchable_id)
        end
      end

      def multisearch_samples
        @multisearch_samples ||= begin
          key = "#{website.cache_key}/api_samples/#{params_values}"
          Rails.cache.fetch(key) do
            approved_completed_samples.where(id: multisearch_ids).load
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

      def keyword
        params[:keyword]&.downcase
      end
    end
  end
end
