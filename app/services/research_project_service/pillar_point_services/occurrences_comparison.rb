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
          FROM asvs
          JOIN research_project_sources
            ON sourceable_id = asvs.sample_id
            and (research_project_sources.sourceable_type = 'Sample')
            AND (research_project_sources.research_project_id =
            #{conn.quote(project.id)})
          JOIN combine_taxa
            ON asvs.taxon_id = combine_taxa.caledna_taxon_id
            AND (source = 'ncbi' OR source = 'bold')
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
          GROUP BY combine_taxa.kingdom
          ORDER BY combine_taxa.kingdom
        SQL

        conn.exec_query(sql)
      end

      def gbif_division_unique_stats
        sql = <<-SQL
          #{gbif_unique_sql}
          GROUP BY combine_taxa.kingdom
          ORDER BY combine_taxa.kingdom
        SQL

        conn.exec_query(sql)
      end
    end
  end
end
