# frozen_string_literal: true

class FetchLaRiverTaxaAsvsCountsJob < ApplicationJob
  include CustomCounter
  include WebsiteStats

  queue_as :default
  after_perform :update_website_stats

  def perform
    puts 'update asvs_count_la_river...'
    reset_counter('asvs_count_la_river')

    puts 'update asvs_count_la_river...'
    results = fetch_asv_counts_for(asvs_count_la_river_sql)

    results.each do |result|
      UpdateLaRiverTaxaAsvsCountJob.perform_later(result['taxon_id'],
                                                  result['count'])
    end
  end

  private

  def update_website_stats
    refresh_pour_website_stats
  end
end
