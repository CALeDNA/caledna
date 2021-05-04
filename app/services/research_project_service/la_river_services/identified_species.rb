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
          ncbi_nodes.asvs_count_la_river as asvs_count, common_names,
          ncbi_divisions.name as division_name,
          ARRAY_AGG(DISTINCT(research_project_sources.metadata ->> 'location'))
            as locations,
          ARRAY_AGG(DISTINCT eol_image) AS eol_images,
          ARRAY_AGG(DISTINCT inat_image) AS inat_images,
          ARRAY_AGG(DISTINCT wikidata_image) AS wikidata_images
          FROM asvs
          JOIN ncbi_nodes
            ON asvs.taxon_id = ncbi_nodes.taxon_id
          JOIN samples
            ON asvs.sample_id = samples.id
          JOIN research_project_sources
            ON research_project_sources.sourceable_id = asvs.sample_id
          LEFT JOIN external_resources
            ON external_resources.ncbi_id = ncbi_nodes.ncbi_id
          LEFT JOIN ncbi_divisions
            ON ncbi_nodes.cal_division_id = ncbi_divisions.id
          WHERE sourceable_type = 'Sample'
          AND research_project_sources.research_project_id IN $1
          AND (
            ncbi_nodes.hierarchy_names ->> 'kingdom' = 'Metazoa'
            OR hierarchy_names ->> 'phylum' = 'Streptophyta'
          )
          AND rank  = 'species'
          GROUP BY ncbi_nodes.taxon_id, ncbi_divisions.name
          ORDER BY asvs_count_la_river DESC;
        SQL

        raw_records =
          conn.exec_query(sql, 'query', [[nil, ResearchProject.la_river_ids]])
        raw_records.map { |r| OpenStruct.new(r) }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
