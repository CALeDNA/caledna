# frozen_string_literal: true

class UpdateLaRiverTaxaAsvsCountJob < ApplicationJob
  include CustomCounter
  queue_as :default

  def perform(taxon_id, count)
    update_count_la_river(taxon_id, count)
  end
end
