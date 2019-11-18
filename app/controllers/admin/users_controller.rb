# frozen_string_literal: true

module Admin
  class UsersController < Admin::ApplicationController
    def download_csv
      filename = "caledna_users_#{Date.today}.csv"
      send_data create_csv, filename: filename
    end

    private

    def create_csv
      require 'csv'

      CSV.generate(headers: true) do |csv|
        csv << %w[username name location email signup_date can_contact]

        User.all.each do |user|
          csv << [user.username, user.name, user.location, user.email,
                  user.created_at.strftime('%F'), user.can_contact]
        end
      end
    end
  end
end
