# frozen_string_literal: true

class SamplesController < ApplicationController
  include PaginatedSamples
  include BatchData

  def index
    @samples = paginated_samples
    @display_name = display_name
    @asvs_count = asvs_count
  end

  def show
    @division_counts = division_counts
    @sample = sample
    @organisms = organisms
    @batch_vernaculars = batch_vernaculars
  end

  private

  def organisms
    @organisms ||= begin
      Asv.joins(ncbi_node: :ncbi_division)
         .joins('LEFT JOIN external_resources ON ' \
           'external_resources.ncbi_id = ncbi_nodes.taxon_id')
         .select('DISTINCT hierarchy_names, ncbi_nodes.taxon_id, ' \
           '"taxonID", iucn_status, name, rank')
         .where(sample: sample)
    end
  end

  def division_counts
    @division_counts ||= begin
      Asv.joins(ncbi_node: :ncbi_division)
         .select(:name)
         .where(sample: sample)
         .group(:name)
         .count
    end
  end

  def sample
    @sample ||= Sample.approved.with_coordinates.find(params[:id])
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
    query[:id] = params[:sample_id] if params[:sample_id]
    query
  end
end
