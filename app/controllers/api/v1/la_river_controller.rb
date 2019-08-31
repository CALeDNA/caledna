# frozen_string_literal: true

module Api
  module V1
    class LaRiverController < Api::V1::ApplicationController
      before_action :add_cors_headers

      include PaginatedSamples
      include BatchData
      include AsvTreeFormatter

      def sites
        render json: {
          samples: SampleSerializer.new(all_samples.la_river),
          asvs_count: asvs_count
        }, status: :ok
      end

      def area_diversity
        render json: area_diversity_json, status: :ok
      end

      def detection_frequency
        render json: project_service.detection_frequency, status: :ok
      end

      def asv_tree
        render json: asv_tree_data, status: :ok
      end

      private

      def project_service
        ResearchProjectService::LaRiver.new(project, params)
      end

      def area_diversity_json
        project_service.area_diversity_data
      end

      def project
        @project ||= begin
          ResearchProject.find_by(slug: 'los-angeles-river')
        end
      end

      def asv_tree_taxa
        @asv_tree_taxa ||=
          fetch_asv_tree_for_research_project(ResearchProject::LA_RIVER.id)
      end

      def asv_tree_data
        tree = asv_tree_taxa.map do |taxon|
          taxon_object = create_taxon_object(taxon)
          create_tree_objects(taxon_object, taxon.rank)
        end.flatten
        tree << { 'name': 'Life', 'id': 'Life', 'common_name': nil }
        tree.uniq! { |i| i[:id] }
      end

      def query_string
        {}
      end
    end
  end
end
