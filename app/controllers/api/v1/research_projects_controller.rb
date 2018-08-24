# frozen_string_literal: true

module Api
  module V1
    class ResearchProjectsController < Api::V1::ApplicationController
      before_action :add_cors_headers
      include PaginatedSamples
      include BatchData

      def show
        render json: {
          samples: SampleSerializer.new(all_samples),
          asvs_count: asvs_count
        }, status: :ok
      end

      private

      def all_samples
        Sample.approved.with_coordinates.order(:barcode).where(id: sample_ids)
      end

      def sample_ids
        sql = 'SELECT sample_id ' \
          'FROM research_project_sources ' \
          'JOIN samples ' \
          'ON samples.id = research_project_sources.sample_id ' \
          "WHERE research_project_sources.research_project_id = #{params[:id]};"

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
