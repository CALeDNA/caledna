# frozen_string_literal: true

module ResearchProjectService
  module PillarPointServices
    module OccurrencesComparison
      def division_counts
        {
          cal: convert_counts(cal_division_stats),
          gbif: convert_counts(gbif_division_stats)
        }
      end

      def division_counts_unique
        {
          cal: convert_counts(cal_division_unique_stats),
          gbif: convert_counts(gbif_division_unique_stats)
        }
      end

      private

      def cal_division_sql
        <<-SQL
          FROM pillar_point.asvs as pp_asvs
          JOIN pillar_point.combine_taxa
            ON pp_asvs.taxon_id = pillar_point.combine_taxa.caledna_taxon_id
            AND (source = 'ncbi' OR source = 'bold')
          WHERE pp_asvs.research_project_id = #{project.id}
          GROUP BY kingdom
          ORDER BY kingdom;
        SQL
      end

      def cal_division_stats
        sql = <<-SQL
          SELECT kingdom AS category, count(*) AS count
          #{cal_division_sql}
        SQL

        conn.exec_query(sql)
      end

      def cal_division_unique_stats
        sql = <<-SQL
          SELECT kingdom as category, COUNT(DISTINCT(taxon_id))
          #{cal_division_sql}
        SQL

        conn.exec_query(sql)
      end

      def gbif_division_stats
        sql = <<-SQL
          #{gbif_division_sql}
          GROUP BY pillar_point.combine_taxa.kingdom
          ORDER BY pillar_point.combine_taxa.kingdom
        SQL

        conn.exec_query(sql)
      end

      def gbif_division_unique_stats
        sql = <<-SQL
          #{gbif_unique_sql}
          GROUP BY pillar_point.combine_taxa.kingdom
          ORDER BY pillar_point.combine_taxa.kingdom
        SQL

        conn.exec_query(sql)
      end
    end
  end
end
