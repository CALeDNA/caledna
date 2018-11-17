# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module ResearchProjectService
  module PillarPointServices
    module GbifSourceComparison
      def gbif_breakdown
        {
          all: convert_counts(gbif_division_unique_stats),
          inat_only: convert_counts(inat_division_unique_stats),
          exclude_inat: convert_counts(exclude_inat_division_unique_stats)
        }
      end

      private

      def inat_division_unique_stats
        sql = gbif_unique_sql
        sql += <<-SQL
            AND (research_project_sources.research_project_id =
              #{conn.quote(project.id)})
            AND (metadata ->> 'location' != 'Montara SMR')
            AND external.gbif_occurrences.datasetkey =
              '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
            ORDER BY kingdom
          ) AS foo
          GROUP BY kingdom
          ORDER BY kingdom;
        SQL
        conn.exec_query(sql)
      end

      def exclude_inat_division_unique_stats
        sql = gbif_unique_sql
        sql += <<-SQL
            AND (research_project_sources.research_project_id =
            #{conn.quote(project.id)})
            AND (metadata ->> 'location' != 'Montara SMR')
            AND external.gbif_occurrences.datasetkey !=
              '50c9509d-22c7-4a22-a47d-8c48425ef4a7'
            ORDER BY kingdom
          ) AS foo
          GROUP BY kingdom;
        SQL
        conn.exec_query(sql)
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
