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
    list_view? ? search_paginated_samples(query) : []
  end

  def counts
    list_view? ? asvs_count : []
  end

  def query
    params[:query]
  end
end
