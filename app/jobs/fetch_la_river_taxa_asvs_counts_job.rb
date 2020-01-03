# frozen_string_literal: true

class FetchLaRiverTaxaAsvsCountsJob < ApplicationJob
  include CustomCounter
  queue_as :default

  def perform
    results = fetch_asv_counts_for(asvs_count_la_river_sql)

    results.each do |result|
      UpdateLaRiverTaxaAsvsCountJob.perform_later(result['taxon_id'],
                                                  result['count'])
    end
  end
end
