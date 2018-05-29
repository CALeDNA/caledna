# frozen_string_literal: true

class ProcessIucnStatusJob < ApplicationJob
  queue_as :default

  def perform(data)
    iucn = ImportIucn.new
    iucn.process_iucn_status(data)
  end
end
