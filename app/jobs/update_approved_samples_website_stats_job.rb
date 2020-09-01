# frozen_string_literal: true

class UpdateApprovedSamplesWebsiteStatsJob < ApplicationJob
  include WebsiteStats

  queue_as :default

  def perform
    change_websites_update_at
    refresh_samples_map
  end
end
