# frozen_string_literal: true

class FetchLaRiverTaxaAsvsCountsJob < ApplicationJob
  include CustomCounter
  include UpdateViewsAndCache

  queue_as :default
  after_perform :update_website_stats

  def perform
    update_asvs_count
    update_asvs_count_la_river
  end

  private

  def update_website_stats
    refresh_views_and_stats
    refresh_pour_website_stats
  end
end
