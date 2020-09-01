# frozen_string_literal: true

class UpdateSamplesStatsAndViewsJob < ApplicationJob
  include WebsiteStats
  queue_as :default

  def perform(update_pour: false)
    refresh_caledna_website_stats
    refresh_pour_website_stats if update_pour
    refresh_samples_map
    refresh_ncbi_nodes_edna
  end
end
