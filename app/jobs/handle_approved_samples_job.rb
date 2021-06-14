# frozen_string_literal: true

class HandleApprovedSamplesJob < ApplicationJob
  include UpdateViewsAndCache

  queue_as :default

  def perform
    refresh_samples_views
    update_websites_via_touch
    Rails.cache.clear
  end
end
