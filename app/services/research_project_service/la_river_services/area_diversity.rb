# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module ResearchProjectService
  module LaRiverServices
    module AreaDiversity
      HAHAMONGNA = 'Hahamongna'
      MAYWOOD = 'Maywood Park'
      WATER = 'water'
      SEDIMENT = 'sediment'

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

      def sampling_types_data
        {
          cal: {
            total: sampling_types_total,
            locations: [
              {
                names: [WATER],
                count: samples_by_type(WATER)
              },
              {
                names: [SEDIMENT],
                count: samples_by_type(SEDIMENT)
              },
              {
                names: [WATER, SEDIMENT],
                count: samples_by_type(WATER, SEDIMENT)
              }
            ]
          }
        }
      end

      private

      # ============================
      # sampling types
      # ============================

      def sampling_types_total
        sql_string = area_diversity_cal_sql

        sql = <<-SQL
        SELECT COUNT(DISTINCT(taxon_id)) FROM (
          #{sql_string}
        ) AS foo
        SQL

        query_results(sql).first['count']
      end

      def samples_by_type(*types)
        sql_array = types.map { |t| sample_type(t) }
        sql_string = sql_array.join(' INTERSECT ')
        sql_string = <<-SQL
        SELECT COUNT(DISTINCT(taxon_id)) FROM (
          #{sql_string}
        ) AS foo
        SQL

        query_results(sql_string).first['count']
      end

      def sample_type(type)
        sql = area_diversity_cal_sql
        sql += " AND samples.substrate_cd = '#{type}'"
        sql
      end

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
        SELECT COUNT(DISTINCT(taxon_id)) FROM (
          #{sql_string}
        ) AS foo
        SQL

        query_results(sql).first['count']
      end

      def pa_taxa_by_location(*locations)
        sql_array = locations.map { |l| pa_area_diversity_cal_location(l) }
        sql_string = sql_array.join(' INTERSECT ')
        sql_string = <<-SQL
        SELECT COUNT(DISTINCT(taxon_id)) FROM (
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
          SELECT asvs.taxon_id
          FROM asvs
          JOIN ncbi_nodes
          ON asvs.taxon_id = ncbi_nodes.taxon_id
          JOIN research_project_sources
          ON research_project_sources.sourceable_id = asvs.sample_id
          JOIN ncbi_divisions
          ON ncbi_divisions.id = ncbi_nodes.cal_division_id
          JOIN samples
          ON asvs.sample_id = samples.id
          WHERE sourceable_type = 'Sample'
          AND research_project_sources.research_project_id = #{project.id}
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
        SELECT COUNT(DISTINCT(taxon_id)) FROM (
          #{sql_string}
        ) AS foo
        SQL

        query_results(sql_string).first['count']
      end

      def taxa_by_location(*locations)
        sql_array = locations.map { |l| area_diversity_cal_location(l) }
        sql_string = sql_array.join(' INTERSECT ')
        sql_string = <<-SQL
        SELECT COUNT(DISTINCT(taxon_id)) FROM (
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
