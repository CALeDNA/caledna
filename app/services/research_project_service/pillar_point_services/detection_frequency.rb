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
          SELECT count(*) AS count,
          pp_combine_taxa.kingdom AS division,
          pp_combine_taxa.kingdom,
          pp_combine_taxa.phylum,
          pp_combine_taxa.#{combine_taxon_rank_field} AS #{taxon_rank},
          'gbif' AS source
          FROM pillar_point.combine_taxa as pp_combine_taxa
          JOIN pillar_point.gbif_occurrences
            ON pp_combine_taxa.source_taxon_id =
              pillar_point.gbif_occurrences.taxonkey
            AND pp_combine_taxa.source = 'gbif'
          JOIN research_project_sources
            ON pillar_point.gbif_occurrences.gbifid =
            research_project_sources.sourceable_id
          WHERE sourceable_type = 'PpGbifOccurrence'
          AND research_project_id = #{project.id}
          AND pp_combine_taxa.#{combine_taxon_rank_field} IS NOT NULL
          AND (metadata ->> 'location' != 'Montara SMR')
          #{taxon_group_filters_sql2}
          GROUP BY pp_combine_taxa.kingdom,
          pp_combine_taxa.phylum,
          pp_combine_taxa.#{combine_taxon_rank_field}
          ORDER BY count DESC
        SQL

        conn.exec_query(sql)
      end

      def biodiversity_bias_cal
        sql = <<~SQL
          SELECT count(*) AS count,
          pp_combine_taxa.kingdom AS division,
          pp_combine_taxa.kingdom,
          pp_combine_taxa.phylum,
          pp_combine_taxa.#{combine_taxon_rank_field} AS #{taxon_rank},
          'ncbi' AS source
          FROM pillar_point.combine_taxa as pp_combine_taxa
          JOIN pillar_point.asvs as pp_asvs
            ON pp_asvs.taxon_id = pp_combine_taxa.caledna_taxon_id
            AND pp_asvs.research_project_id = #{project.id}
          WHERE (pp_combine_taxa.source = 'ncbi' OR
            pp_combine_taxa.source = 'bold')
          AND pp_combine_taxa.#{combine_taxon_rank_field} IS NOT NULL
          #{taxon_group_filters_sql2}
          GROUP BY pp_combine_taxa.kingdom,
          pp_combine_taxa.phylum,
          pp_combine_taxa.#{combine_taxon_rank_field}
          ORDER BY count DESC
        SQL

        conn.exec_query(sql)
      end

      def taxon_group_filters_sql2
        return if taxon_groups.blank?

        " AND lower(pp_combine_taxa.kingdom) in (#{selected_taxon_groups})"
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
