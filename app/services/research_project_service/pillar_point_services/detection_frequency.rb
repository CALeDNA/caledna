# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module ResearchProjectService
  module PillarPointServices
    module DetectionFrequency
      def biodiversity_bias
        {
          cal: biodiversity_bias_cal,
          gbif: biodiversity_bias_gbif
        }
      end

      def biodiversity_bias_gbif
        sql = <<~SQL
          SELECT count(*) AS count, combine_taxa.kingdom AS division,
          combine_taxa.kingdom,
          combine_taxa.phylum,
          combine_taxa.#{combine_taxon_rank_field} AS #{taxon_rank},
          'gbif' AS source
          FROM combine_taxa
          JOIN external.gbif_occurrences
            ON combine_taxa.source_taxon_id = external.gbif_occurrences.taxonkey
            AND combine_taxa.source = 'gbif'
          JOIN research_project_sources
            ON external.gbif_occurrences.gbifid =
            research_project_sources.sourceable_id
          WHERE sourceable_type = 'GbifOccurrence'
          AND research_project_id = #{project.id}
          AND combine_taxa.#{combine_taxon_rank_field} IS NOT NULL
          AND (metadata ->> 'location' != 'Montara SMR')
          #{taxon_group_filters_sql2}
          GROUP BY combine_taxa.kingdom,
          combine_taxa.phylum,
          combine_taxa.#{combine_taxon_rank_field}
          ORDER BY count DESC
        SQL

        conn.exec_query(sql)
      end

      def biodiversity_bias_cal
        sql = <<~SQL
          SELECT count(*) AS count, combine_taxa.kingdom AS division,
          combine_taxa.kingdom,
          combine_taxa.phylum,
          combine_taxa.#{combine_taxon_rank_field} AS #{taxon_rank},
          'ncbi' AS source
          FROM combine_taxa
          JOIN asvs
            ON asvs.taxon_id = combine_taxa.caledna_taxon_id
            AND (combine_taxa.source = 'ncbi' OR combine_taxa.source = 'bold')
          JOIN research_project_sources
            ON asvs.sample_id = research_project_sources.sourceable_id
          WHERE sourceable_type = 'Sample'
          AND research_project_sources.research_project_id = #{project.id}
          AND combine_taxa.#{combine_taxon_rank_field} IS NOT NULL
          #{taxon_group_filters_sql2}
          GROUP BY combine_taxa.kingdom,
          combine_taxa.phylum,
          combine_taxa.#{combine_taxon_rank_field}
          ORDER BY count DESC
        SQL

        conn.exec_query(sql)
      end

      def taxon_group_filters_sql2
        return if taxon_groups.blank?

        " AND lower(combine_taxa.kingdom) in (#{selected_taxon_groups})"
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
