# frozen_string_literal: true

module ResearchProjectService
  module PillarPointServices
    module TaxonomyComparison
      def taxonomy_comparison_data
        gbif = 'gbif'
        edna = 'edna'

        {
          sources: [
            { names: [gbif], count: taxa_total_gbif },
            { names: [edna], count: taxa_total_edna },
            { names: [gbif, edna], count: taxa_total_common }
          ]
        }
      end

      private

      def taxa_total_edna
        sql_string = <<-SQL
          SELECT COUNT(DISTINCT(kingdom, "#{combine_taxon_rank_field}")) FROM (
            #{taxa_total_edna_sql}
          ) AS foo;
        SQL

        query_results(sql_string).first['count']
      end

      def taxa_total_gbif
        sql_string = <<-SQL
          SELECT COUNT(DISTINCT(kingdom, "#{combine_taxon_rank_field}")) FROM (
            #{taxa_total_gbif_sql}
          ) AS foo;
        SQL

        query_results(sql_string).first['count']
      end

      def taxa_total_common
        sql_string = <<-SQL
          SELECT COUNT(DISTINCT(kingdom, "#{combine_taxon_rank_field}")) FROM (
            #{taxa_total_edna_sql}
            INTERSECT
            #{taxa_total_gbif_sql}
          ) AS foo;
        SQL

        query_results(sql_string).first['count']
      end

      def taxa_total_edna_sql
        <<-SQL
          SELECT pillar_point.combine_taxa.kingdom,
            pillar_point.combine_taxa.#{combine_taxon_rank_field}
          FROM pillar_point.combine_taxa
          LEFT JOIN pillar_point.asvs as pp_asvs
            ON pp_asvs.taxon_id = pillar_point.combine_taxa.caledna_taxon_id
            AND pp_asvs.research_project_id = #{project.id}
          WHERE (pillar_point.combine_taxa.source = 'ncbi' OR
            pillar_point.combine_taxa.source = 'bold')
          AND pillar_point.combine_taxa.#{combine_taxon_rank_field} IS NOT NULL
          #{taxon_group_filters_sql}
        SQL
      end

      def taxa_total_gbif_sql
        <<-SQL
          SELECT pillar_point.combine_taxa.kingdom,
            pillar_point.combine_taxa.#{combine_taxon_rank_field}
          FROM pillar_point.combine_taxa
          JOIN external.gbif_occurrences
            ON external.gbif_occurrences.taxonkey =
              pillar_point.combine_taxa.source_taxon_id
          JOIN research_project_sources
            ON external.gbif_occurrences.gbifid =
              research_project_sources.sourceable_id
            AND research_project_id = #{project.id}
            AND sourceable_type = 'GbifOccurrence'
            AND metadata ->> 'location' != 'Montara SMR'
          WHERE  pillar_point.combine_taxa.source = 'gbif'
          AND pillar_point.combine_taxa.#{combine_taxon_rank_field} IS NOT NULL
          #{taxon_group_filters_sql}
        SQL
      end

      def taxon_group_filters_sql
        return if taxon_groups.blank?

        ' AND lower(pillar_point.combine_taxa.kingdom) in ' \
          "(#{selected_taxon_groups})"
      end
    end
  end
end
