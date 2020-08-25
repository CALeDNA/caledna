# frozen_string_literal: true

class FetchTaxaAsvsCountsJob < ApplicationJob
  include CustomCounter
  queue_as :default
  after_perform :refresh_samples_map

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

  def refresh_samples_map
    sql = 'REFRESH MATERIALIZED VIEW samples_map;'

    ActiveRecord::Base.connection.exec_query(sql)
  end
end
