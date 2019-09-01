# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module ResearchProjectService
  module LaRiverServices
    module AreaDiversity
      HAHAMONGNA = 'Hahamongna'
      MAYWOOD = 'Maywood Park'
      def area_diversity_data
        {
          cal: {
            total: taxa_total,
            locations: [
              {
                names: [HAHAMONGNA],
                count: taxa_by_location(HAHAMONGNA)
              },
              {
                names: [MAYWOOD],
                count: taxa_by_location(MAYWOOD)
              },
              {
                names: [HAHAMONGNA, MAYWOOD],
                count: taxa_by_location(HAHAMONGNA, MAYWOOD)
              }
            ]
          }
        }
      end

      def pa_area_diversity_data
        {
          cal: {
            total: pa_taxa_total,
            locations: [
              {
                names: [HAHAMONGNA],
                count: pa_taxa_by_location(HAHAMONGNA)
              },
              {
                names: [MAYWOOD],
                count: pa_taxa_by_location(MAYWOOD)
              },
              {
                names: [HAHAMONGNA, MAYWOOD],
                count: pa_taxa_by_location(HAHAMONGNA, MAYWOOD)
              }
            ]
          }
        }
      end

      private

      # ============================
      # plants and animals taxa
      # ============================

      def pa_sql
        <<-SQL
          AND (
            hierarchy_names ->> 'kingdom' = 'Metazoa'
            OR hierarchy_names ->> 'phylum' = 'Streptophyta'
          )
        SQL
      end

      def pa_taxa_total
        sql_string = area_diversity_cal_sql
        sql_string += pa_sql

        sql = <<-SQL
        SELECT COUNT(DISTINCT("taxonID")) FROM (
          #{sql_string}
        ) AS foo
        SQL

        query_results(sql).first['count']
      end

      def pa_taxa_by_location(*locations)
        sql_array = locations.map { |l| pa_area_diversity_cal_location(l) }
        sql_string = sql_array.join(' INTERSECT ')
        sql_string = <<-SQL
        SELECT COUNT(DISTINCT("taxonID")) FROM (
          #{sql_string}
        ) AS foo
        SQL

        query_results(sql_string).first['count']
      end

      def pa_area_diversity_cal_location(location)
        sql = area_diversity_cal_sql
        sql += pa_sql
        sql += " AND samples.metadata ->> 'location'"
        sql += " = '#{location}'"
        sql
      end

      # ============================
      # base sql
      # ============================

      def area_diversity_cal_sql
        sql = <<-SQL
          SELECT asvs."taxonID"
          FROM asvs
          JOIN ncbi_nodes
          ON asvs."taxonID" = ncbi_nodes.taxon_id
          JOIN research_project_sources
          ON research_project_sources.sourceable_id = asvs.extraction_id
          JOIN ncbi_divisions
          ON ncbi_divisions.id = ncbi_nodes.cal_division_id
          JOIN samples
          ON asvs.sample_id = samples.id
          WHERE sourceable_type = 'Extraction'
          AND research_project_id = #{project.id}
          AND rank = 'species'
        SQL

        if taxon_groups
          sql += " AND ncbi_divisions.name in (#{selected_taxon_groups})"
        end

        sql
      end

      def months
        params['months']
      end

      # ============================
      # total taxa
      # ============================

      def taxa_total
        sql_string = area_diversity_cal_sql
        sql_string = <<-SQL
        SELECT COUNT(DISTINCT("taxonID")) FROM (
          #{sql_string}
        ) AS foo
        SQL

        query_results(sql_string).first['count']
      end

      def taxa_by_location(*locations)
        sql_array = locations.map { |l| area_diversity_cal_location(l) }
        sql_string = sql_array.join(' INTERSECT ')
        sql_string = <<-SQL
        SELECT COUNT(DISTINCT("taxonID")) FROM (
          #{sql_string}
        ) AS foo
        SQL

        query_results(sql_string).first['count']
      end

      def area_diversity_cal_location(location)
        sql = area_diversity_cal_sql
        sql += " AND samples.metadata ->> 'location'"
        sql += " = '#{location}'"
        sql
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
