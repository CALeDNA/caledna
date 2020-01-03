# frozen_string_literal: true

class FetchTaxaAsvsCountsJob < ApplicationJob
  include CustomCounter
  queue_as :default

  def perform
    results = fetch_asv_counts_for(asvs_count_sql)

    results.each do |result|
      UpdateTaxaAsvsCountJob.perform_later(result['taxon_id'], result['count'])
    end
  end
end
