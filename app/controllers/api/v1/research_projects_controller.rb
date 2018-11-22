# frozen_string_literal: true

module Api
  module V1
    class ResearchProjectsController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include PaginatedSamples
      include BatchData

      def show
        render json: response_json, status: :ok
      end

      def pillar_point_area_diversity
        render json: area_diversity_json, status: :ok
      end

      def pillar_point_source_comparison_all
        render json: source_comparison_all_json, status: :ok
      end

      def pillar_point_biodiversity_bias
        project = ResearchProject.find_by(name: 'Pillar Point')
        pp = ResearchProjectService::PillarPoint.new(project, params)

        render json: pp.biodiversity_bias, status: :ok
      end

      def pillar_point_occurrences
        project = ResearchProject.find_by(name: 'Pillar Point')
        pp = ResearchProjectService::PillarPoint.new(project, params)

        render json: {
          occurrences: pp.division_counts,
          unique_taxa: pp.division_counts_unique
        }, status: :ok
      end

      private

      def source_comparison_all_json
        project = ResearchProject.find_by(name: 'Pillar Point')
        pp = ResearchProjectService::PillarPoint.new(project, params)
        pp.source_comparison_all_data
      end

      def area_diversity_json
        project = ResearchProject.find_by(name: 'Pillar Point')
        pp = ResearchProjectService::PillarPoint.new(project, params)
        pp.area_diversity_data
      end

      def conn
        @conn ||= ActiveRecord::Base.connection
      end

      def response_json
        json = {
          samples: SampleSerializer.new(all_samples),
          asvs_count: asvs_count
        }
        json.merge!(pillar_point_data) if include_research?
        json
      end

      def include_research?
        params[:include_research] == 'true'
      end

      def ncbi_id
        params[:ncbi_id]
      end

      def id
        params[:id]
      end

      def pillar_point_data
        pp = ResearchProjectService::PillarPoint.new(project, params)
        occurrences =
          ncbi_id ? pp.gbif_occurrences_by_taxa : pp.gbif_occurrences
        {
          research_project_data: {
            gbif_occurrences: GbifOccurrenceSerializer.new(occurrences)
          }
        }
      end

      def project
        @project ||= begin
          where_sql = id.to_i.zero? ? 'slug = ?' : 'id = ?'
          ResearchProject.where(where_sql, id).first
        end
      end

      def all_samples
        Sample.approved.with_coordinates.order(:barcode).where(id: sample_ids)
      end

      # rubocop:disable Metrics/MethodLength
      def sample_ids
        sql = 'SELECT research_project_sources.sample_id ' \
          'FROM research_project_sources ' \
          'JOIN samples ' \
          'ON samples.id = research_project_sources.sample_id ' \

        if ncbi_id.present?
          sql += <<-SQL
          JOIN asvs ON samples.id = asvs.sample_id
          JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs."taxonID"
          SQL
        end

        sql +=
          "WHERE research_project_sources.research_project_id = #{project.id}"

        sql += "AND  ids @> '{#{ncbi_id}}'" if ncbi_id.present?

        @sample_ids ||= ActiveRecord::Base.connection.execute(sql)
                                          .pluck('sample_id')
      end
      # rubocop:enable Metrics/MethodLength

      def query_string
        query = {}
        query[:research_project_id] = id
        query
      end
    end
  end
end
