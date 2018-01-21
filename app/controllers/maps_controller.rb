class MapsController < ApplicationController
  def show
    @markers =
      Sample.joins(:project)
            .select(:latitude, :longitude, :bar_code, :id, :submission_date,
                    'projects.name', :project_id)
            .all
  end
end
