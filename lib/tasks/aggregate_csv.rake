# frozen_string_literal: true

namespace :aggregate_csv do
  task taxa_table: :environment do
    Primer.all.each do |primer|
      taxa_table = AggregateTaxaTables.new(primer)
      taxa_table.create_taxa_table_csv
    end
  end
end
