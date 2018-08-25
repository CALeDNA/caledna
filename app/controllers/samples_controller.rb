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
    @organisms_groups = organisms_groups
    @batch_vernaculars = batch_vernaculars
  end

  private

  def organisms_groups
    @organisms_groups ||= begin
      sample.extractions.map do |e|
        {
          extraction_name: e.extraction_type.name,
          organisms: organisms_by_extraction(e.id)
        }
      end
    end
  end

  def organisms_by_extraction(extraction_id)
    Asv.joins(ncbi_node: :ncbi_division)
       .joins('LEFT JOIN external_resources ON ' \
         'external_resources.ncbi_id = ncbi_nodes.taxon_id')
       .select('lineage, ncbi_nodes.taxon_id, iucn_status, name, rank')
       .where(extraction_id: extraction_id)
  end

  def division_counts
    @division_counts ||= begin
      sample.extractions.map do |e|
        {
          id: e.id,
          counts: division_counts_by_extraction(e.id)
        }
      end
    end
  end

  def division_counts_by_extraction(extraction_id)
    Asv.joins(ncbi_node: :ncbi_division)
       .select(:name)
       .where(extraction_id: extraction_id)
       .group(:name)
       .count
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
