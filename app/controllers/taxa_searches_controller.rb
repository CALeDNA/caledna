# frozen_string_literal: true

class TaxaSearchesController < ApplicationController
  def show
    if params[:search]
      @matches = matches
      @query = search_params[:query]
    else
      @matches = []
      @query = nil
    end
  end

  private

  def matches
    matches = []
    matches += taxa_matches if taxa_matches.present?
    matches += vernaculars_matches if vernaculars_matches.present?
    matches
  end

  def taxa_matches
    NcbiNode.where("lower(\"canonical_name\") = '#{query}'")
  end

  def vernaculars_matches
    vernacular_ids =
      NcbiName.where("lower(\"name\") = '#{query}'").pluck(:taxon_id)
    NcbiNode.where(taxon_id: vernacular_ids)
  end

  def query
    search_params[:query].downcase
  end

  def search_params
    params.require(:search).permit(:query)
  end
end
