# frozen_string_literal: true

namespace :global_names do
  task import_pillar_point_inat_taxa: :environment do
    include ImportGlobalNames
    global_names_api = ::GlobalNamesApi.new

    inat_taxa =
      InatObservation
      .select(:scientificName, :taxonID)
      .joins(:research_project_sources)
      .where("research_project_sources.sourceable_type = 'InatObservation'")
      .group(:scientificName, :taxonID)

    inat_taxa.each do |taxon|
      results = global_names_api.names(taxon.scientificName)
      create_external_resource(results: results, taxon_id: taxon.id,
                               id_name: 'inaturalist_id', rank: taxon.taxonRank)
    end
  end

  task create_external_resources_for_gbif_taxa: :environment do
    include ImportGlobalNames
    global_names_api = ::GlobalNamesApi.new
    conn = ActiveRecord::Base.connection

    sql = <<-SQL
    SELECT taxonkey, scientificname
    FROM external.gbif_occ_taxa
    LEFT JOIN external_resources
    ON external.gbif_occ_taxa.taxonkey = external_resources.gbif_id
    WHERE gbif_id IS NULL;
    SQL

    records = conn.exec_query(sql).to_a

    records.each do |record|
      puts record['taxonkey']

      source_ids = ExternalResource::GLOBAL_NAMES_SOURCE_IDS.join('|')
      results = global_names_api.names(record['scientificname'], source_ids)

      create_external_resource(results: results, taxon_id: record['taxonkey'],
                               id_name: 'gbif_id')
    end
  end

  task create_external_resource_for_globi: :environment do
    include ImportGlobalNames
    global_names_api = ::GlobalNamesApi.new
    conn = ActiveRecord::Base.connection

    project = ResearchProject.find_by(name: 'Pillar Point')

    sql = <<-SQL
    SELECT taxon_name,
      research_project_sources.metadata ->> 'inat_id' as inat_id
    FROM external.globi_requests
    JOIN research_project_sources
    ON research_project_sources.sourceable_id = external.globi_requests.id
    LEFT JOIN external_resources
      ON external_resources.inaturalist_id = (research_project_sources.metadata ->> 'inat_id')::integer
      AND external_resources.source = 'globalnames',
    WHERE research_project_id = #{project.id}
    AND sourceable_type = 'GlobiRequest',
    AND gbif_id IS NULL
    SQL

    records = conn.exec_query(sql).to_a

    records.each do |record|
      puts record['taxon_name']

      source_ids = ExternalResource::GLOBAL_NAMES_SOURCE_IDS.join('|')
      results = global_names_api.names(record['taxon_name'], source_ids)

      create_external_resource(
        results: results, taxon_id: record['inat_id'],
        id_name: 'inaturalist_id',
      )
    end
  end
end
