# frozen_string_literal: true

namespace :iunc_data do
  desc 'update iunc status'
  task update_iunc_status: :environment do
    iucn = ImportIucn.new
    raw_data = iucn.connect
    statuses = raw_data['result']

    statuses.each do |status|
      UpdateIucnStatusJob.perform_later(status)
    end
  end
end
