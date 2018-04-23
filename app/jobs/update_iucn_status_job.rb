# frozen_string_literal: true

class UpdateIucnStatusJob < ApplicationJob
  queue_as :default

  def perform(data)
    iucn = ImportIucn.new
    iucn.update_iucn_status(data)
  end
end
