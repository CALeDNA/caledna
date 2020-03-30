# frozen_string_literal: true

module ResearchProjectService
  module LaRiverServices
    module OccurrencesComparison
      def division_counts
        {
          cal: convert_counts(cal_division_stats),
          inat: convert_counts(inat_division_stats)
        }
      end

      def division_counts_unique
        {
          cal: convert_counts(cal_division_unique_stats),
          inat: convert_counts(inat_division_unique_stats)
        }
      end

      private

      def cal_division_sql
        <<-SQL
          FROM asvs
          JOIN research_project_sources
          ON sourceable_id = asvs.sample_id
          AND (research_project_sources.sourceable_type = 'Sample')
          AND (research_project_sources.research_project_id = #{project.id})
          JOIN ncbi_nodes
          ON ncbi_nodes.taxon_id = asvs.taxon_id
          JOIN ncbi_divisions
          ON ncbi_divisions.id = ncbi_nodes.cal_division_id
          GROUP BY ncbi_divisions.name
          ORDER BY ncbi_divisions.name;
        SQL
      end

      def cal_division_stats
        sql = <<-SQL
          SELECT ncbi_divisions.name AS category, count(*) AS count
          #{cal_division_sql}
        SQL

        conn.exec_query(sql)
      end

      def cal_division_unique_stats
        sql = <<-SQL
          SELECT ncbi_divisions.name AS category, COUNT(DISTINCT(taxon_id))
          #{cal_division_sql}
        SQL

        conn.exec_query(sql)
      end

      def inat_division_sql
        <<-SQL
          FROM external.inat_observations as inat_obs
          JOIN research_project_sources
          ON sourceable_id = inat_obs.observation_id
          AND (research_project_sources.sourceable_type = 'InatObservation')
          AND (research_project_sources.research_project_id =#{project.id})
          JOIN external.inat_taxa as inat_taxa
          ON inat_taxa.taxon_id = inat_obs.taxon_id
          GROUP BY kingdom
          ORDER BY kingdom;
        SQL
      end

      def inat_division_stats
        sql = <<-SQL
          SELECT kingdom AS category, count(*) AS count
          #{inat_division_sql}
        SQL

        conn.exec_query(sql)
      end

      def inat_division_unique_stats
        sql = <<-SQL
          SELECT kingdom AS category, COUNT(DISTINCT(inat_taxa.taxon_id))
          #{inat_division_sql}
        SQL

        conn.exec_query(sql)
      end
    end
  end
end
