# frozen_string_literal: true

class SamplesController < ApplicationController
  def index
    @samples = Sample.order(:bar_code).where(query_string).page params[:page]
  end

  def show
    @sample = Sample.find(params[:id])
  end

  private

  def query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    query[:project_id] = params[:project_id] if params[:project_id]
    query[:id] = params[:sample_id] if params[:sample_id]
    query
  end
end
