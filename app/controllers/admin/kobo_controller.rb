module Admin
  class KoboController < Admin::ApplicationController

    def list_projects
      @projects = ::KoboApi.new.projects.parsed_response
    end

  end
end
