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
    list_view? ? paginated_samples(query_string: { id: multisearch_ids }) : []
  end

  def counts
    list_view? ? asvs_count : []
  end

  def multisearch_ids
    @multisearch_ids ||= PgSearch.multisearch(query).pluck(:searchable_id)
  end

  def query
    params[:query]
  end
end
