# frozen_string_literal: true

class UpdateTaxaAsvsCountJob < ApplicationJob
  include CustomCounter
  queue_as :default

  def perform(taxon_id, count)
    update_count(taxon_id, count)
  end
end
