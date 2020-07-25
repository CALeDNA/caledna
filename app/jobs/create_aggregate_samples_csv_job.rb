# frozen_string_literal: true

class CreateAggregateSamplesCsvJob < ApplicationJob
  queue_as :default

  def perform
    AggregateCsv.new.create_sample_metadata_csv
  end
end
