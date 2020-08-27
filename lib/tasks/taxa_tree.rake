# frozen_string_literal: true

namespace :taxa_tree do
  task create_la_river_csv: :environment do
    include AsvTreeFormatter

    tree = fetch_asv_tree_for_research_project(ResearchProject.la_river.id)
    File.write('./app/javascript/data/la_river_taxa_tree.json', tree.to_json)
  end
end
