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
    Taxon.where("lower(\"canonicalName\") = '#{query}'")
  end

  def vernaculars_matches
    vernacular_ids =
      Vernacular.where("lower(\"vernacularName\") = '#{query}'").pluck(:taxonID)
    Taxon.where(taxonID: vernacular_ids)
  end

  def query
    search_params[:query].downcase
  end

  def search_params
    params.require(:search).permit(:query)
  end
end
