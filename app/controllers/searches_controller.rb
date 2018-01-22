# frozen_string_literal: true

class SearchesController < ApplicationController
  def show
    search_results = PgSearch.multisearch(search_params[:query])
    ids = search_results.pluck(:searchable_id)
    @samples = Sample.where(id: ids).page params[:page]
    @query = search_params[:query]
  end

  private

  def search_params
    params.require(:search).permit(:query)
  end
end
