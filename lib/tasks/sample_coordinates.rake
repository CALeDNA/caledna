# frozen_string_literal: true

namespace :sample_coordinates do
  require 'csv'
  require_relative '../../app/services/import_csv/update_coordinates'
  include ImportCsv::UpdateCoordinates

  task import: :environment do
    path = "#{Rails.root}/public/seed/sample_coords.csv"

    CSV.foreach(path, headers: true) do |row|
      update_coordinates(row)
    end
  end
end
