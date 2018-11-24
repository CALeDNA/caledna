# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
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
            convert_counts(exclude_inat_division_occurrences_stats),
        }
      end

      private

      def inat_division_occurrences_stats
        sql = gbif_division_sql
        sql += <<-SQL
          AND external.gbif_occurrences.datasetkey =
          '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
          GROUP BY kingdom
          ORDER BY kingdom
        SQL

        conn.exec_query(sql)
      end

      def exclude_inat_division_occurrences_stats
        sql = gbif_division_sql
        sql += <<-SQL
          AND external.gbif_occurrences.datasetkey !=
          '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
          GROUP BY kingdom
          ORDER BY kingdom
        SQL

        conn.exec_query(sql)
      end

      def inat_division_unique_stats
        sql = gbif_unique_sql
        sql += <<-SQL
          AND external.gbif_occurrences.datasetkey =
              '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
          GROUP BY kingdom
          ORDER BY kingdom;
        SQL
        conn.exec_query(sql)
      end

      def exclude_inat_division_unique_stats
        sql = gbif_unique_sql
        sql += <<-SQL
          AND external.gbif_occurrences.datasetkey !=
            '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
          GROUP BY kingdom
          ORDER BY kingdom;
        SQL
        conn.exec_query(sql)
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
