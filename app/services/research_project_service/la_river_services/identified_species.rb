# frozen_string_literal: true

module ResearchProjectService
  module LaRiverServices
    module IdentifiedSpecies
      def identified_species_by_location
        identified_species.group_by(&:locations)
      end

      # rubocop:disable Metrics/MethodLength
      def identified_species
        sql = <<-SQL
          SELECT ncbi_nodes.taxon_id, ncbi_nodes.canonical_name,
          ncbi_nodes.asvs_count_la_river as asvs_count,
          ARRAY_AGG(DISTINCT(samples.metadata ->> 'location')) as locations,
          ARRAY_AGG(DISTINCT(ncbi_names.name)) as common_names,
          ARRAY_AGG(DISTINCT eol_image) AS eol_images,
          ARRAY_AGG(DISTINCT inat_image) AS inat_images,
          ARRAY_AGG(DISTINCT wikidata_image) AS wikidata_images
          FROM asvs
          JOIN ncbi_nodes
            ON asvs."taxonID" = ncbi_nodes.taxon_id
          LEFT JOIN ncbi_names
            ON ncbi_names.taxon_id = ncbi_nodes.taxon_id
            AND ncbi_names.name_class IN ('common name', 'genbank common name')
          JOIN samples
            ON asvs.sample_id = samples.id
          JOIN research_project_sources
            ON research_project_sources.sourceable_id = asvs.extraction_id
          LEFT JOIN external_resources
            ON external_resources.ncbi_id = ncbi_nodes.ncbi_id
          WHERE sourceable_type = 'Extraction'
          AND research_project_id = $1
          AND (
            ncbi_nodes.hierarchy_names ->> 'kingdom' = 'Metazoa'
            OR hierarchy_names ->> 'phylum' = 'Streptophyta'
          )
          AND rank  = 'species'
          GROUP BY ncbi_nodes.taxon_id, ncbi_nodes.canonical_name,
          ncbi_nodes.asvs_count_la_river
          ORDER BY asvs_count_la_river DESC;
        SQL

        raw_records =
          conn.exec_query(sql, 'query', [[nil, ResearchProject::LA_RIVER.id]])
        raw_records.map { |r| OpenStruct.new(r) }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
