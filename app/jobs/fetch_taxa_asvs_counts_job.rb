# frozen_string_literal: true

class FetchTaxaAsvsCountsJob < ApplicationJob
  include CustomCounter
  include UpdateViewsAndCache

  queue_as :default
  after_perform :update_website_stats

  def perform
    update_asvs_count
  end

  private

  def update_website_stats
    refresh_views_and_stats
  end
end
