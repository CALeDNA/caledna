# frozen_string_literal: true

module ResearchProjectService
  module PillarPointServices
    module GbifSourceComparison
      def gbif_breakdown
        {
          inat_only_unique:
            convert_counts(inat_division_unique_stats),
          exclude_inat_unique:
            convert_counts(exclude_inat_division_unique_stats),
          inat_only_occurrences:
            convert_counts(inat_division_occurrences_stats),
          exclude_inat_occurrences:
            convert_counts(exclude_inat_division_occurrences_stats)
        }
      end

      private

      def inat_division_occurrences_stats
        sql = <<-SQL
          #{gbif_division_sql}
          AND external.gbif_occurrences.datasetkey =
          '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
          GROUP BY combine_taxa.kingdom
          ORDER BY combine_taxa.kingdom;
        SQL

        conn.exec_query(sql)
      end

      def exclude_inat_division_occurrences_stats
        sql = <<-SQL
          #{gbif_division_sql}
          AND external.gbif_occurrences.datasetkey !=
          '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
          GROUP BY combine_taxa.kingdom
          ORDER BY combine_taxa.kingdom;
        SQL

        conn.exec_query(sql)
      end

      def inat_division_unique_stats
        sql = <<-SQL
          #{gbif_unique_sql}
          AND external.gbif_occurrences.datasetkey =
          '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
          GROUP BY combine_taxa.kingdom
          ORDER BY combine_taxa.kingdom;
        SQL
        conn.exec_query(sql)
      end

      def exclude_inat_division_unique_stats
        sql = <<-SQL
          #{gbif_unique_sql}
          AND external.gbif_occurrences.datasetkey !=
          '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
          GROUP BY combine_taxa.kingdom
          ORDER BY combine_taxa.kingdom;
        SQL
        conn.exec_query(sql)
      end
    end
  end
end
