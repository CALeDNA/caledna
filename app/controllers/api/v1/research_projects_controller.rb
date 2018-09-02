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

      private

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

      def pillar_point_data
        pp = ResearchProjectService::PillarPoint.new(project, params)

        {
          research_project_data: {
            gbif_occurrences: GbifOccurrenceSerializer.new(pp.gbif_occurrences)
          }
        }
      end

      def project
        @project ||= begin
          where_sql = params[:id].to_i.zero? ? 'slug = ?' : 'id = ?'
          ResearchProject.where(where_sql, params[:id]).first
        end
      end

      def all_samples
        Sample.approved.with_coordinates.order(:barcode).where(id: sample_ids)
      end

      def sample_ids
        sql = 'SELECT sample_id ' \
          'FROM research_project_sources ' \
          'JOIN samples ' \
          'ON samples.id = research_project_sources.sample_id ' \
          "WHERE research_project_sources.research_project_id = #{project.id};"

        @sample_ids ||= ActiveRecord::Base.connection.execute(sql)
                                          .pluck('sample_id')
      end

      def query_string
        query = {}
        query[:research_project_id] = params[:id]
        query
      end
    end
  end
end
