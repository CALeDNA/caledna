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
          phylum, "#{gbif_taxon_rank_field}" AS #{taxon_rank}, 'gbif' AS source
          FROM external.gbif_occurrences
          JOIN research_project_sources
          ON external.gbif_occurrences.gbifid = research_project_sources.sourceable_id
          WHERE sourceable_type = 'GbifOccurrence'
          AND research_project_id = #{project.id}
          AND "#{gbif_taxon_rank_field}" IS NOT NULL
          AND (metadata ->> 'location' != 'Montara SMR')
          #{kingdoms_sql}
          GROUP BY kingdom, phylum, "#{gbif_taxon_rank_field}"
        SQL

        conn.exec_query(sql)
      end

      def kingdoms_sql
        return if taxon_groups.blank?

        kingdoms = selected_taxon_groups.to_s[1..-2].tr('"', "'")
        "AND kingdom in (#{kingdoms})"
      end

      def biodiversity_bias_cal
        sql = <<~SQL
          SELECT count(*) AS count, ncbi_divisions.name AS division,
          hierarchy_names ->> 'phylum' AS phylum,
          hierarchy_names ->> '#{taxon_rank}' AS #{taxon_rank}, 'ncbi' AS source
          FROM asvs
          JOIN research_project_sources
          ON asvs.extraction_id = research_project_sources.sourceable_id
          JOIN ncbi_nodes
          ON ncbi_nodes.taxon_id = asvs."taxonID"
          JOIN ncbi_divisions
          on ncbi_nodes.cal_division_id = ncbi_divisions.id
          WHERE sourceable_type = 'Extraction'
          AND research_project_id = #{project.id}
          AND hierarchy_names ->> '#{taxon_rank}' IS NOT NULL
          AND ncbi_divisions.name != 'Environmental samples'
          #{taxon_group_filters_sql2}
          GROUP BY ncbi_divisions.name,
          hierarchy_names ->> 'phylum',
          hierarchy_names ->> '#{taxon_rank}'
          ORDER BY count DESC
        SQL

        conn.exec_query(sql)
      end

      def taxon_group_filters_sql2
        return if taxon_groups.blank?

        " AND ncbi_nodes.cal_division_id in (#{selected_taxon_groups_ids})"
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
