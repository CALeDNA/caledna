# frozen_string_literal: true

module ResearchProjectService
  module PillarPointServices
    module SourceComparisonAll
      def source_comparison_all_data
        gbif = 'gbif'
        edna = 'edna'

        {
          total: taxa_total,
          sources: [
            { names: [gbif], count: taxa_total_gbif },
            { names: [edna], count: taxa_total_edna },
            { names: [gbif, edna], count: taxa_total_common }
          ]
        }
      end

      private

      def taxa_total
        sql_string = <<-SQL
          SELECT COUNT(DISTINCT("#{taxon_rank_value}")) FROM (
            #{taxa_total_edna_sql}
            UNION
            #{taxa_total_gbif_sql}
          ) AS foo;
        SQL

        query_results(sql_string).first['count']
      end

      def taxa_total_edna
        sql_string = <<-SQL
          SELECT COUNT(DISTINCT("#{taxon_rank_value}")) FROM (
            #{taxa_total_edna_sql}
          ) AS foo;
        SQL

        query_results(sql_string).first['count']
      end

      def taxa_total_gbif
        sql_string = <<-SQL
          SELECT COUNT(DISTINCT("#{taxon_rank_value}")) FROM (
            #{taxa_total_gbif_sql}
          ) AS foo;
        SQL

        query_results(sql_string).first['count']
      end

      def taxa_total_common
        sql_string = <<-SQL
          SELECT COUNT(DISTINCT("#{taxon_rank_value}")) FROM (
            #{taxa_total_edna_sql}
            INTERSECT
            #{taxa_total_gbif_sql}
          ) AS foo;
        SQL

        query_results(sql_string).first['count']
      end

      def taxa_total_edna_sql
        <<-SQL
          SELECT combine_taxa.#{taxon_rank_value}
          FROM combine_taxa
          LEFT JOIN asvs
            ON asvs."taxonID" = combine_taxa.taxon_id
          JOIN research_project_sources
            ON asvs.extraction_id = research_project_sources.sourceable_id
            AND research_project_id = #{project.id}
            AND sourceable_type = 'Extraction'
          WHERE  combine_taxa.source = 'ncbi'
          AND combine_taxa.#{taxon_rank_value} IS NOT NULL
          #{taxon_group_sql}
        SQL
      end

      def taxa_total_gbif_sql
        <<-SQL
          SELECT  combine_taxa.#{taxon_rank_value}
          FROM combine_taxa
          JOIN external.gbif_occurrences
            ON external.gbif_occurrences.taxonkey = combine_taxa.taxon_id
          JOIN research_project_sources
            ON external.gbif_occurrences.gbifid =
              research_project_sources.sourceable_id
            AND research_project_id = #{project.id}
            AND sourceable_type = 'GbifOccurrence'
            AND metadata ->> 'location' != 'Montara SMR'
          WHERE  combine_taxa.source = 'gbif'
          AND combine_taxa.#{taxon_rank_value} IS NOT NULL
          #{taxon_group_sql}
        SQL
      end

      def taxon_group_sql
        return if taxon_groups.blank?
        taxa = taxon_groups
               .gsub('plants', '14|4')
               .gsub('animals', '12')
               .gsub('fungi', '13')
               .gsub('bacteria', '0|9')
               .gsub('archaea', '16')
               .gsub('chromista', '17')

        filters = taxa.split('|').join(', ')
        " AND combine_taxa.cal_division_id in (#{filters})"
      end

      def taxon_rank_value
        taxon_ranks == 'class' ? 'class_name' : taxon_ranks
      end

      def taxon_groups
        params['taxon_groups']
      end

      def taxon_ranks
        params['taxon_ranks'] || 'phylum'
      end
    end
  end
end
