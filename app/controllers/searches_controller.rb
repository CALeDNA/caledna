# frozen_string_literal: true

class SearchesController < ApplicationController
  include PaginatedSamples

  def show
    @samples = paginated_samples
    @query = search_params[:query]
  end

  private

  def samples
    samples = []
    samples += multisearch_samples if multisearch_samples.present?
    samples += taxa_samples if taxa_samples.present?
    samples += vernaculars_samples if vernaculars_samples.present?
    samples
  end

  def taxa_ids
    query = search_params[:query].downcase
    Taxon.where("lower(\"canonicalName\") = '#{query}'").pluck(:taxonID)
  end

  def taxa_samples
    @taxa_samples ||=
      Asv.where(taxonID: taxa_ids).map { |a| a.extraction.sample }
  end

  def vernacular_taxa_ids
    query = search_params[:query].downcase
    vernacular_ids =
      Vernacular.where("lower(\"vernacularName\") = '#{query}'").pluck(:taxonID)
    Taxon.where(taxonID: vernacular_ids).pluck(:taxonID)
  end

  def vernaculars_samples
    @vernaculars_samples ||=
      Asv.where(taxonID: vernacular_taxa_ids).map { |a| a.extraction.sample }
  end

  def multisearch_ids
    search_results = PgSearch.multisearch(search_params[:query])
    search_results.pluck(:searchable_id)
  end

  def multisearch_samples
    @multisearch_samples ||= Sample.approved.where(id: multisearch_ids)
  end

  def search_params
    params.require(:search).permit(:query)
  end
end
