# frozen_string_literal: true

class SamplesController < ApplicationController
  include PaginatedSamples

  def index
    @samples = paginated_samples
    @display_name = display_name
    @asvs_count = asvs_count
  end

  def show
    @asvs_count = asvs_count(params[:sample_id])
    @sample = Sample.approved
                    .includes(extractions: { asvs: { ncbi_node: :ncbi_names } })
                    .find(params[:id])
  end

  private

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
    query[:id] = params[:sample_id] if params[:sample_id]
    query
  end
end
