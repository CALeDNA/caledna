# frozen_string_literal: true

class SamplesController < ApplicationController
  def index
    @samples = Sample.order(:bar_code).where(query_string).page params[:page]
    @display_name = display_name
  end

  def show
    @sample = Sample.find(params[:id])
  end

  private

  # TODO: add test
  def display_name
    if params[:project_id]
      Project.select(:name).find(params[:project_id]).name
    elsif params[:sample_id]
      Sample.select(:bar_code).find(params[:sample_id]).bar_code
    end
  end

  def query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    query[:project_id] = params[:project_id] if params[:project_id]
    query[:id] = params[:sample_id] if params[:sample_id]
    query
  end
end
