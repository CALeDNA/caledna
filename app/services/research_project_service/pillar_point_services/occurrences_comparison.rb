# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
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

      def cal_division_stats
        sql = <<-SQL
          SELECT "name" AS category, COUNT(name) AS count
          FROM "asvs"
          INNER JOIN "ncbi_nodes"
          ON "ncbi_nodes"."taxon_id" = "asvs"."taxonID"
          INNER JOIN "ncbi_divisions"
          ON "ncbi_divisions"."id" = "ncbi_nodes"."cal_division_id"
          JOIN research_project_sources
          ON sourceable_id = extraction_id
          WHERE (research_project_sources.sourceable_type = 'Extraction')
          AND (research_project_sources.research_project_id =
            #{conn.quote(project.id)})

          GROUP BY name
          ORDER BY name;
        SQL

        conn.exec_query(sql)
      end

      def cal_division_unique_stats
        sql = <<-SQL
          SELECT name as category, count("taxonID") FROM (
          SELECT distinct("taxonID"), name
          FROM "asvs"
          JOIN "ncbi_nodes" ON "ncbi_nodes"."taxon_id" = "asvs"."taxonID"
          JOIN "ncbi_divisions"
          ON "ncbi_divisions"."id" = "ncbi_nodes"."cal_division_id"
          JOIN research_project_sources ON sourceable_id = extraction_id
          WHERE (research_project_sources.sourceable_type = 'Extraction')
          AND (research_project_sources.research_project_id =
            #{conn.quote(project.id)})
          ORDER BY name
          ) AS foo
          GROUP BY name;
        SQL

        conn.exec_query(sql)
      end

      def gbif_division_unique_stats
        sql = gbif_unique_sql
        sql += <<-SQL
          GROUP BY kingdom
          ORDER BY kingdom
        SQL

        conn.exec_query(sql)
      end

      def gbif_division_sql
        <<-SQL
          SELECT  kingdom as category, count(kingdom)
          FROM external.gbif_occurrences
          JOIN research_project_sources
          ON research_project_sources.sourceable_id =
            external.gbif_occurrences.gbifid
          WHERE (research_project_sources.sourceable_type = 'GbifOccurrence')
          AND (research_project_sources.research_project_id =
            #{conn.quote(project.id)})
          AND (metadata ->> 'location' != 'Montara SMR')
          AND kingdom IS NOT NULL
        SQL
      end

      def gbif_division_stats
        sql = <<-SQL
          #{gbif_division_sql}
          GROUP BY kingdom
          ORDER BY kingdom
        SQL

        conn.exec_query(sql)
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
