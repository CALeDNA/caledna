# frozen_string_literal: true

namespace :research_la_river_point do
  require 'csv'

  task add_sample_metadata: :environment do
    path = "#{Rails.root}/db/data/private/la_river_sample_metadata.csv"

    puts 'import sample metadata'

    CSV.foreach(path, headers: true) do |row|
      attributes = {
        metadata: {
          location: row['location'],
          river_state: row['river_state'],
          sample_type: row['sample_type']
        }
      }
      sample = Sample.find(row['id'])
      sample.update(attributes)
    end
  end
end
