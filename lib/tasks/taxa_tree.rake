# frozen_string_literal: true

namespace :taxa_tree do
  task create_la_river_csv: :environment do
    include AsvTreeFormatter

    taxa = fetch_asv_tree_for_research_project(ResearchProject::LA_RIVER.id)

    tree = taxa.map do |taxon|
      taxon_object = create_taxon_object(taxon)
      create_tree_objects(taxon_object, taxon.rank)
    end.flatten
    tree << { 'name': 'Life', 'id': 'Life', 'common_name': nil }
    tree.uniq! { |i| i[:id] }

    File.write('./app/javascript/data/la_river_taxa_tree.json', tree.to_json)
  end
end
