# frozen_string_literal: true

namespace :global_names do
  task import_pillar_point_inat_taxa: :environment do
    include ImportGlobalNames

    inat_taxa =
      InatObservation
      .select(:scientificName, :taxonID)
      .joins(:research_project_sources)
      .where("research_project_sources.sourceable_type = 'InatObservation'")
      .group(:scientificName, :taxonID)

    service = ::GlobalNamesApi.new

    inat_taxa.each do |taxon|
      results = service.names(taxon.scientificName)
      create_external_resource(results, taxon)
    end
  end
end
