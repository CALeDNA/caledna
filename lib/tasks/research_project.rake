# frozen_string_literal: true

namespace :research_project do
  require 'csv'

  task import_pillar_point_sources: :environment do
    path = "#{Rails.root}/db/data/private/pillar_point_sources.csv"

    puts 'import pillar point sources'

    project_id = ResearchProject.find_by(name: 'Pillar Point').id

    CSV.foreach(path, headers: true) do |row|
      attributes = {
        research_project_id: project_id,
        sourceable_id: row['id'].to_i,
        sourceable_type: 'InatObservation'
      }
      ResearchProjectSource.create(attributes)
    end
  end
end
