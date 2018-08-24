# frozen_string_literal: true

class FieldDataProjectsController < ApplicationController
  include PaginatedSamples
  include BatchData

  def index
    @projects =
      FieldDataProject
      .where('id IN (SELECT DISTINCT(field_data_project_id) from samples)')
      .order(:name).page params[:page]
  end

  def show
    @samples = samples
    @project = FieldDataProject.find(params[:id])
    @asvs_count = counts
  end

  private

  def counts
    if params[:view]
      asvs_count
    else
      []
    end
  end

  def samples
    if params[:view]
      paginated_samples
    else
      []
    end
  end

  def query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    project_id = params[:id]
    query[:field_data_project_id] = project_id if project_id
    query
  end
end
