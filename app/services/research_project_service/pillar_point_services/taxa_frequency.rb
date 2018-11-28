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
          SELECT count(*) AS count, ncbi_divisions.name AS division,
          combine_taxa.phylum,
          combine_taxa.#{combine_taxon_rank_field} AS #{taxon_rank},
          'gbif' AS source
          FROM combine_taxa
          JOIN external.gbif_occurrences
            ON combine_taxa.taxon_id = external.gbif_occurrences.taxonkey
            AND combine_taxa.source = 'gbif'
          JOIN research_project_sources
            ON external.gbif_occurrences.gbifid =
            research_project_sources.sourceable_id
          JOIN ncbi_divisions
            ON combine_taxa.cal_division_id = ncbi_divisions.id
          WHERE sourceable_type = 'GbifOccurrence'
          AND research_project_id = #{project.id}
          AND combine_taxa.#{combine_taxon_rank_field} IS NOT NULL
          AND (metadata ->> 'location' != 'Montara SMR')
          #{taxon_group_filters_sql2}
          GROUP BY ncbi_divisions.name,
          combine_taxa.phylum,
          combine_taxa.#{combine_taxon_rank_field}
          ORDER BY count DESC
        SQL

        conn.exec_query(sql)
      end

      def biodiversity_bias_cal
        sql = <<~SQL
          SELECT count(*) AS count, ncbi_divisions.name AS division,
          combine_taxa.phylum,
          combine_taxa.#{combine_taxon_rank_field} AS #{taxon_rank},
          'ncbi' AS source
          FROM combine_taxa
          JOIN asvs
            ON asvs."taxonID" = combine_taxa.taxon_id
            AND combine_taxa.source = 'ncbi'
          JOIN research_project_sources
            ON asvs.extraction_id = research_project_sources.sourceable_id
          JOIN ncbi_divisions
            ON combine_taxa.cal_division_id = ncbi_divisions.id
          WHERE sourceable_type = 'Extraction'
          AND research_project_id = #{project.id}
          AND combine_taxa.#{combine_taxon_rank_field} IS NOT NULL
          AND ncbi_divisions.name != 'Environmental samples'
          #{taxon_group_filters_sql2}
          GROUP BY ncbi_divisions.name,
          combine_taxa.phylum,
          combine_taxa.#{combine_taxon_rank_field}
          ORDER BY count DESC
        SQL

        conn.exec_query(sql)
      end

      def taxon_group_filters_sql2
        return if taxon_groups.blank?

        " AND combine_taxa.cal_division_id in (#{selected_taxon_groups_ids})"
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
