# frozen_string_literal: true

class SearchesController < ApplicationController
  include PaginatedSamples

  def show
    @samples = paginated_samples
    @query = search_params[:query]
  end

  private

  def samples
    search_results = PgSearch.multisearch(search_params[:query])
    ids = search_results.pluck(:searchable_id)
    Sample.approved.where(id: ids)
  end

  def search_params
    params.require(:search).permit(:query)
  end
end
