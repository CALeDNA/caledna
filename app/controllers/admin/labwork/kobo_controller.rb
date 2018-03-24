# frozen_string_literal: true

module Admin
  module Labwork
    class KoboController < Admin::ApplicationController
      def import_kobo
        authorize 'Labwork::Kobo'.to_sym, :import_kobo?

        @projects = ::FieldDataProject.all.where.not(kobo_id: nil)
      end

      def import_projects
        authorize 'Labwork::Kobo'.to_sym, :import_projects?

        hash_data = ::KoboApi::Connect.projects.parsed_response
        results = kobo_process.import_projects(hash_data)

        flash[:error] = 'Could not save data from Kobo API.' unless results
        redirect_to action: 'import_kobo'
      rescue SocketError
        flash[:error] = 'Could not get new data from Kobo API.'
        redirect_to action: 'import_kobo'
      end

      # rubocop:disable Metrics/AbcSize
      def import_samples
        authorize 'Labwork::Kobo'.to_sym, :import_samples?

        hash_data = ::KoboApi::Connect.project(project.kobo_id).parsed_response
        results =
          kobo_process.import_samples(project.id, project.kobo_id, hash_data)

        flash[:error] = 'Could not save data from Kobo API.' unless results
        redirect_to action: 'import_kobo'
      rescue SocketError
        flash[:error] = 'Could not get new data from Kobo API.'
        redirect_to action: 'import_kobo'
      end
      # rubocop:enable Metrics/AbcSize

      private

      def kobo_process
        ::KoboApi::Process.new
      end

      def project
        @project = FieldDataProject.find(params[:id])
      end
    end
  end
end