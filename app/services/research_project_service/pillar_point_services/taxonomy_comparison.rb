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
          SELECT combine_taxa.kingdom, combine_taxa.#{combine_taxon_rank_field}
          FROM combine_taxa
          LEFT JOIN asvs
            ON asvs.taxon_id = combine_taxa.caledna_taxon_id
          JOIN research_project_sources
            ON asvs.sample_id = research_project_sources.sourceable_id
            AND research_project_sources.research_project_id = #{project.id}
            AND sourceable_type = 'Sample'
          WHERE  (combine_taxa.source = 'ncbi' or combine_taxa.source = 'bold')
          AND combine_taxa.#{combine_taxon_rank_field} IS NOT NULL
          #{taxon_group_filters_sql}
        SQL
      end

      def taxa_total_gbif_sql
        <<-SQL
          SELECT combine_taxa.kingdom, combine_taxa.#{combine_taxon_rank_field}
          FROM combine_taxa
          JOIN external.gbif_occurrences
            ON external.gbif_occurrences.taxonkey = combine_taxa.source_taxon_id
          JOIN research_project_sources
            ON external.gbif_occurrences.gbifid =
              research_project_sources.sourceable_id
            AND research_project_id = #{project.id}
            AND sourceable_type = 'GbifOccurrence'
            AND metadata ->> 'location' != 'Montara SMR'
          WHERE  combine_taxa.source = 'gbif'
          AND combine_taxa.#{combine_taxon_rank_field} IS NOT NULL
          #{taxon_group_filters_sql}
        SQL
      end

      def taxon_group_filters_sql
        return if taxon_groups.blank?

        " AND lower(combine_taxa.kingdom) in (#{selected_taxon_groups})"
      end
    end
  end
end
