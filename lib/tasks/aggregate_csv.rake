# frozen_string_literal: true

namespace :aggregate_csv do
  task taxa_table: :environment do
    Primer.all.each do |primer|
      taxa_table = AggregateTaxaTables.new(primer)
      taxa_table.create_taxa_results_csv
    end
  end

  task samples_table: :environment do
    taxa_table = AggregateTaxaTables.new(nil)
    taxa_table.create_sample_metadata_csv
  end
end
