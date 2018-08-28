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

    global_names_api = ::GlobalNamesApi.new

    inat_taxa.each do |taxon|
      results = global_names_api.names(taxon.scientificName)
      create_external_resource(results: results, taxon_id: taxon.id,
                               id_name: 'inaturalist_id', rank: taxon.taxonRank)
    end
  end

  task import_gbif_taxa: :environment do
    include ImportGlobalNames
    global_names_api = ::GlobalNamesApi.new

    GbifOccTaxa.all.each do |taxon|
      puts taxon.taxonkey

      resource =
        ExternalResource.find_by(gbif_id: taxon.taxonkey, source: 'globalnames')
      next if resource.present?

      source_ids = ExternalResource::GLOBAL_NAMES_SOURCE_IDS.join('|')
      results = global_names_api.names(taxon.scientificname, source_ids)

      create_external_resource(results: results, taxon_id: taxon.taxonkey,
                               id_name: 'gbif_id')
    end
  end
end
