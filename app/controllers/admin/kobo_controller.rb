# frozen_string_literal: true

module Admin
  class KoboController < Admin::ApplicationController
    def import_kobo
      authorize :import_kobo, :import_kobo?

      @projects = ::Project.all.where.not(kobo_id: nil)
    end

    def import_projects
      authorize :import_kobo, :import_projects?

      hash_data = ::KoboApi::Connect.projects.parsed_response
      results = ::KoboApi::Process.import_projects(hash_data)
      flash[:error] = 'Could not save data from Kobo API.' unless results
      redirect_to action: 'import_kobo'
    rescue SocketError
      flash[:error] = 'Could not get new data from Kobo API.'
      redirect_to action: 'import_kobo'
    end

    def import_samples
      authorize :import_kobo, :import_samples?

      hash_data = ::KoboApi::Connect.project(project.kobo_id).parsed_response
      results = ::KoboApi::Process.import_samples(project.id, hash_data)

      flash[:error] = 'Could not save data from Kobo API.' unless results
      redirect_to action: 'import_kobo'
    rescue SocketError
      flash[:error] = 'Could not get new data from Kobo API.'
      redirect_to action: 'import_kobo'
    end

    private

    def project
      @project = Project.find(params[:id])
    end
  end
end
