# frozen_string_literal: true

namespace :counter_reset do
  desc 'reset taxa asvs_count'
  task taxa_asvs_count: :environment do
    Asv.pluck(:taxonID).uniq.each do |id|
      print '.'
      Taxon.reset_counters id, :asvs
    end
  end
end
