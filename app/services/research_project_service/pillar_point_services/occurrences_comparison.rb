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
          SELECT kingdom AS category, count(*) AS count
          FROM asvs
          JOIN research_project_sources
            ON sourceable_id = asvs.extraction_id
            and (research_project_sources.sourceable_type = 'Extraction')
            AND (research_project_sources.research_project_id =
            #{conn.quote(project.id)})
          JOIN combine_taxa
            ON asvs."taxonID" = combine_taxa.caledna_taxon_id
            AND (source = 'ncbi' OR source = 'bold')
          GROUP BY kingdom
          ORDER BY kingdom;
        SQL

        conn.exec_query(sql)
      end

      def cal_division_unique_stats
        sql = <<-SQL
          SELECT kingdom AS category, count("taxonID") FROM (
            SELECT DISTINCT("taxonID"), kingdom
            FROM asvs
            JOIN research_project_sources
              ON sourceable_id = asvs.extraction_id
              AND (research_project_sources.sourceable_type = 'Extraction')
              AND (research_project_sources.research_project_id = 4)
            JOIN combine_taxa
              ON asvs."taxonID" = combine_taxa.caledna_taxon_id
              AND (source = 'ncbi'  OR source = 'bold')
              GROUP BY "taxonID", kingdom
          ) AS foo
          GROUP BY kingdom
          ORDER BY kingdom;
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
