# frozen_string_literal: true

class UpdateApprovedSamplesWebsiteStatsJob < ApplicationJob
  include WebsiteStats

  queue_as :default

  def perform
    refresh_samples_map
    refresh_ncbi_nodes_edna
    refresh_caledna_website_stats
    refresh_pour_website_stats
    Rails.cache.clear
  end
end
