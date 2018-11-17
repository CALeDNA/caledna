# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module ResearchProjectService
  module PillarPointServices
    module TaxaFrequency
      def biodiversity_bias
        {
          cal: biodiversity_bias_cal,
          gbif: biodiversity_bias_gbif
        }
      end

      def biodiversity_bias_gbif
        sql = <<~SQL
          SELECT count(*) AS count, kingdom AS division,
          phylum, classname AS class, 'gbif' AS source
          FROM external.gbif_occurrences
          JOIN research_project_sources
          ON external.gbif_occurrences.gbifid = research_project_sources.sourceable_id
          WHERE sourceable_type = 'GbifOccurrence'
          AND research_project_id = 4
          AND classname IS NOT NULL
          AND (metadata ->> 'location' != 'Montara SMR')
          GROUP BY kingdom, phylum, classname
        SQL

        conn.exec_query(sql)
      end

      def biodiversity_bias_cal
        sql = <<~SQL
          SELECT count(*) AS count, ncbi_divisions.name AS division,
          hierarchy_names ->> 'phylum' AS phylum,
          hierarchy_names ->> 'class' AS class, 'ncbi' AS source
          FROM asvs
          JOIN research_project_sources
          ON asvs.extraction_id = research_project_sources.sourceable_id
          JOIN ncbi_nodes
          ON ncbi_nodes.taxon_id = asvs."taxonID"
          JOIN ncbi_divisions
          on ncbi_nodes.cal_division_id = ncbi_divisions.id
          WHERE sourceable_type = 'Extraction'
          AND research_project_id = 4
          AND hierarchy_names ->> 'class' IS NOT NULL
          AND ncbi_divisions.name != 'Environmental samples'
          GROUP BY ncbi_divisions.name,
          hierarchy_names ->> 'phylum',
          hierarchy_names ->> 'class'
          ORDER BY count DESC
        SQL

        conn.exec_query(sql)
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
