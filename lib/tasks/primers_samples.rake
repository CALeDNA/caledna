# frozen_string_literal: true

namespace :primers_sample do
  require 'csv'

  task import_primers: :environment do
    include UpdateSamples
    puts 'updating sample primers...'
    Asv.where("primers::TEXT != '{}'").find_each do |asv|
      # puts "#{asv.sample_id} - #{asv.primers}"

      add_primers_from_asv(asv)
    end
  end
end
