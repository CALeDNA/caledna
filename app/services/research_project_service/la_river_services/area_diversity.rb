# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module ResearchProjectService
  module LaRiverServices
    module AreaDiversity
      def area_diversity_data
        hahamongna = 'Hahamongna'
        maywood = 'Maywood Park'

        {
          cal: {
            total: cal_total,
            locations: [
              { names: [hahamongna], count: cal_location(hahamongna) },
              { names: [maywood], count: cal_location(maywood) },
              { names: [hahamongna, maywood],
                count: cal_location(hahamongna, maywood) }
            ]
          }
        }
      end

      private

      def cal_total
        sql_string = area_diversity_cal_sql
        sql_string = <<-SQL
        SELECT COUNT(DISTINCT("taxonID")) FROM (
          #{sql_string}
        ) AS foo
        SQL

        query_results(sql_string).first['count']
      end

      def cal_location(*locations)
        sql_array = locations.map { |l| area_diversity_cal_location(l) }
        sql_string = sql_array.join(' INTERSECT ')
        sql_string = <<-SQL
        SELECT COUNT(DISTINCT("taxonID")) FROM (
          #{sql_string}
        ) AS foo
        SQL

        query_results(sql_string).first['count']
      end

      def area_diversity_cal_sql
        @area_diversity_cal_sql = begin
          sql = <<-SQL
            SELECT asvs."taxonID"
            FROM asvs
            JOIN ncbi_nodes
            ON asvs."taxonID" = ncbi_nodes.taxon_id
            JOIN research_project_sources
            ON research_project_sources.sourceable_id = asvs.extraction_id
            JOIN samples
            ON asvs.sample_id = samples.id
            WHERE sourceable_type = 'Extraction'
            AND research_project_id = #{project.id}
          SQL

          if taxon_groups
            sql += " AND ncbi_divisions.name in (#{selected_taxon_groups})"
          end

          sql
        end
      end

      def area_diversity_cal_location(location)
        sql = area_diversity_cal_sql
        sql += " AND samples.metadata ->> 'location'"
        sql += " = '#{location}'"
        sql
      end

      def months
        params['months']
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
