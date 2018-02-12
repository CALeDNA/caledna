# frozen_string_literal: true

class FieldDataProjectsController < ApplicationController
  include PaginatedSamples

  def index
    @projects = FieldDataProject.order(:name).page params[:page]
  end

  def show
    @samples = paginated_samples
    @project = FieldDataProject.find(params[:id])
  end

  private

  def query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    project_id = params[:id]
    query[:field_data_project_id] = project_id if project_id
    query
  end
end
