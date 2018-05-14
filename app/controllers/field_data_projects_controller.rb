# frozen_string_literal: true

class FieldDataProjectsController < ApplicationController
  include PaginatedSamples

  def index
    @projects =
      FieldDataProject
      .where('id IN (SELECT DISTINCT(field_data_project_id) from samples)')
      .order(:name).page params[:page]
  end

  def show
    @samples = paginated_samples
    @project = FieldDataProject.find(params[:id])
    @asvs_count = asvs_count
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
