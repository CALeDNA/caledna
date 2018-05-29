# frozen_string_literal: true

namespace :iunc_data do
  desc 'update iunc status'
  task update_iunc_status: :environment do
    iucn = ImportIucn.new
    raw_data = iucn.connect
    statuses = raw_data['result']

    statuses.each_with_index do |status, i|
      delay = i * 0.25
      ProcessIucnStatusJob.set(wait: delay).perform_later(status)
    end
  end
end
