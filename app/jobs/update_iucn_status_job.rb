# frozen_string_literal: true

class UpdateIucnStatusJob < ApplicationJob
  queue_as :default

  def perform(data, taxon)
    iucn = ImportIucn.new
    iucn.update_iucn_status(data, taxon)
  end
end
