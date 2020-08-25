# frozen_string_literal: true

class FetchLaRiverTaxaAsvsCountsJob < ApplicationJob
  include CustomCounter
  queue_as :default
  after_perform :refresh_samples_map

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

  def refresh_samples_map
    sql = 'REFRESH MATERIALIZED VIEW samples_map;'

    ActiveRecord::Base.connection.exec_query(sql)
  end
end
