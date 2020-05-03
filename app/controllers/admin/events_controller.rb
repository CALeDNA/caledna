# frozen_string_literal: true

module Admin
  class EventsController < Admin::ApplicationController
    layout :resolve_layout

    def download_csv
      filename = "#{event.name}_registrations_#{Date.today}.csv"
      send_data create_csv, filename: filename
    end

    private

    def event
      Event.find(params[:id])
    end

    def create_csv
      require 'csv'

      CSV.generate(headers: true) do |csv|
        csv << %w[username email status registration\ date]

        event.event_registrations.each do |registration|
          csv << [registration.user.username, registration.user.email,
                  registration.created_at.strftime('%F'),
                  registration.status_cd]
        end
      end
    end
  end
end
