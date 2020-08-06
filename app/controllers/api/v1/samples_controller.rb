# frozen_string_literal: true

module Api
  module V1
    class SamplesController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include FilterSamples
      include AsvTreeFormatter
      include TreeFormatter

      def index
        render json: {
          samples: SampleSerializer.new(samples)
        }, status: :ok
      end

      def show
        render json: {
          sample: SampleSerializer.new(sample)
        }, status: :ok
      end

      def taxa_list
        render json: {
          taxa_list: asv_tree_taxa
        }, status: :ok
      end

      private

      # =======================
      # show
      # =======================

      def sample
        @sample ||= begin
          sql = <<~SQL
            LEFT JOIN research_project_sources  as rps
            ON rps.sourceable_id = samples.id
            AND sourceable_type = 'Sample'
            LEFT JOIN research_projects
            ON research_projects.id = rps.research_project_id
            AND research_projects.published = true
          SQL
          website_sample.select(sample_columns).joins(sql)
                        .where(conditional_status_sql)
                        .find(sample_id)
        end
      end

      def sample_id
        params[:id] || params[:sample_id]
      end

      def asv_tree_taxa
        @asv_tree_taxa ||= fetch_asv_tree_for_sample(sample.id)
      end

      def organisms
        @organisms ||= begin
          fetch_nested_taxa_tree_for_sample(sample_id)
        end
      end

      # =======================
      # index
      # =======================

      def samples
        @samples ||= keyword.present? ? multisearch_samples : approved_samples
      end

      def multisearch_ids
        @multisearch_ids ||= begin
          search_results = PgSearch.multisearch(keyword)
          search_results.pluck(:searchable_id)
        end
      end

      def multisearch_samples
        @multisearch_samples ||= approved_samples.where(id: multisearch_ids)
      end

      def keyword
        params[:keyword]&.downcase
      end
    end
  end
end
