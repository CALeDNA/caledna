# frozen_string_literal: true

module Api
  module V1
    class StatsController < Api::V1::ApplicationController
      before_action :add_cors_headers

      def home_page
        stats = {
          samples_approved: Sample.approved.with_coordinates.count,
          users: User::EXISTING_USERS + User.count + 500,
          organisms: organism_count.first['count']
        }

        render json: stats, status: :ok
      end

      private

      def organism_count
        @organism_count ||= begin
          sql = 'SELECT COUNT(DISTINCT(taxon_id)) from asvs;'
          ActiveRecord::Base.connection.execute(sql)
        end
      end
    end
  end
end
