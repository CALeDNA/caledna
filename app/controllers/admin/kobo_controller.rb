# frozen_string_literal: true

module Admin
  class KoboController < Admin::ApplicationController
    def list_projects
      import_projects
      @projects = ::Project.all
    end

    private

    def import_projects
      hash_data = ::KoboApi::Connect.projects.parsed_response
      results = ::KoboApi::Process.import_projects(hash_data)
      flash[:error] = 'Could not save data from Kobo API.' unless results
    rescue SocketError
      flash[:error] = 'Could not get new data from Kobo API.'
    end
  end
end
