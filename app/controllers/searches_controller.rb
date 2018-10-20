# frozen_string_literal: true

class SearchesController < ApplicationController
  include PaginatedSamples
  include BatchData

  def show
    @query = query
    @samples = samples
    @asvs_count = counts
  end

  private

  def samples
    params[:view] == 'list' ? paginated_samples : []
  end

  def counts
    params[:view] == 'list' ? asvs_count : []
  end

  def all_samples
    raw_samples = []
    raw_samples += multisearch_samples if multisearch_samples.present?
    raw_samples
  end

  def multisearch_ids
    search_results = PgSearch.multisearch(query)
    search_results.pluck(:searchable_id)
  end

  def multisearch_samples
    @multisearch_samples ||=
      Sample.includes(:field_data_project).approved.with_coordinates
            .where(id: multisearch_ids)
  end

  def query
    params[:query]
  end

  def query_string
    {}
  end
end
