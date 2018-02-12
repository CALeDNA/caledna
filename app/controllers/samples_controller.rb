# frozen_string_literal: true

class SamplesController < ApplicationController
  def index
    @samples = paginated_samples
    @display_name = display_name
  end

  def show
    @sample = Sample.find(params[:id])
  end

  private

  def paginated_samples
    if params[:view]
      samples.page(params[:page])
    else
      samples
    end
  end

  def samples
    Sample.approved.order(:barcode).where(query_string)
  end

  # TODO: add test
  def display_name
    if params[:field_data_project_id]
      FieldDataProject.select(:name).find(params[:field_data_project_id]).name
    elsif params[:sample_id]
      Sample.select(:barcode).find(params[:sample_id]).barcode
    end
  end

  def query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    project_id = params[:field_data_project_id]
    query[:field_data_project_id] = project_id if project_id
    query[:id] = params[:sample_id] if params[:sample_id]
    query
  end
end
