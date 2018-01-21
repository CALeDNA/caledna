# frozen_string_literal: true

class MapsController < ApplicationController
  def show
    @markers =
      Sample.joins(:project)
            .select(:latitude, :longitude, :bar_code, :id, :submission_date,
                    'projects.name', :project_id, :status_cd)
            .where(query_string)
            .all
  end

  def query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    query[:project_id] = params[:project_id] if params[:project_id]
    query
  end
end
