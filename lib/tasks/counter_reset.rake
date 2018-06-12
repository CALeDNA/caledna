# frozen_string_literal: true

namespace :counter_reset do
  require_relative '../../app/services/custom_counter'
  include CustomCounter

  desc 'reset ncbi_nodes asvs_count'
  task asvs_count: :environment do
    update_asvs_counts
  end
end
