# frozen_string_literal: true

class CreateAggregateTaxaCsvJob < ApplicationJob
  queue_as :default

  def perform(primer)
    AggregateCsv.new(primer).create_taxa_results_csv
  end
end
