# frozen_string_literal: true

namespace :inat_obs do
  require_relative '../../app/services/import_csv/inat_observations'
  include ImportCsv::InatObservations

  # bin/rake inat_obs:import_la_river_observations[<path>,<location>]
  task :create_la_river_inat_observations,
       %i[path location] => :environment do |_t, args|
    path = args[:path]
    location = args[:location]
    project_name = 'Los Angeles River'
    puts 'import inat ...'

    import_observations_csv(path, project_name, location)
  end
end
