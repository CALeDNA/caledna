# frozen_string_literal: true

class FetchTaxaAsvsCountsJob < ApplicationJob
  include CustomCounter
  include WebsiteStats

  queue_as :default
  after_perform :update_website_stats

  def perform
    puts 'reset asvs_count...' if Rails.env.development?
    reset_counter('asvs_count')

    puts 'update asvs_count...' if Rails.env.development?
    results = fetch_asv_counts_for(asvs_count_sql)

    results.each do |result|
      UpdateTaxaAsvsCountJob.perform_later(result['taxon_id'], result['count'])
    end
  end

  private

  def update_website_stats
    refresh_caledna_website_stats
  end
end
