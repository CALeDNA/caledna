class SearchesController < ApplicationController
  def show
    @search_results = PgSearch.multisearch(search_params[:query])
  end

  private

  def search_params
    params.require(:search).permit(:query)
  end
end
