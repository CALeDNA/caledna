# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
# rubocop:disable Metrics/PerceivedComplexity
module ResearchProjectService
  module PillarPointServices
    module AreaDiversity
      def area_diversity_data
        smca = 'Pillar Point SMCA'
        exposed = 'Pillar Point exposed unprotected'
        embankment = 'Pillar Point embankment unprotected'

        {
          cal: {
            total: cal_total,
            locations: [
              { names: [smca], count: cal_location(smca) },
              { names: [exposed], count: cal_location(exposed) },
              { names: [embankment], count: cal_location(embankment) },
              { names: [smca, exposed], count: cal_location(smca, exposed) },
              {
                names: [embankment, exposed],
                count: cal_location(embankment, exposed)
              },
              {
                names: [smca, embankment],
                count: cal_location(smca, embankment)
              },
              {
                names: [smca, embankment, exposed],
                count: cal_location(smca, embankment, exposed)
              }
            ]
          },
          gbif: {
            total: gbif_total,
            locations: [
              { names: [smca], count: gbif_location(smca) },
              { names: [exposed], count: gbif_location(exposed) },
              { names: [embankment], count: gbif_location(embankment) },
              { names: [smca, exposed], count: gbif_location(smca, exposed) },
              {
                names: [embankment, exposed],
                count: gbif_location(embankment, exposed)
              },
              {
                names: [smca, embankment],
                count: gbif_location(smca, embankment)
              },
              {
                names: [smca, embankment, exposed],
                count: gbif_location(smca, embankment, exposed)
              }
            ]
          }
        }
      end

      private

      def gbif_total
        sql_string = area_diversity_gbif_sql
        sql_string += "AND metadata ->> 'location' != 'Montara SMR'"
        sql_string = <<-SQL
        SELECT COUNT(DISTINCT(taxonkey)) FROM (
          #{sql_string}
        ) AS foo
        SQL

        query_results(sql_string).first['count']
      end

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

      def gbif_location(*locations)
        sql_array = locations.map { |l| area_diversity_gbif_location(l) }
        sql_string = sql_array.join(' INTERSECT ')
        sql_string = <<-SQL
        SELECT COUNT(DISTINCT(taxonkey)) FROM (
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
            sql += " AND ncbi_nodes.cal_division_id in (#{selected_taxon_groups_ids})"
          end

          if months
            filters = months.split('|').map(&:titlecase)
            sql += " AND samples.metadata ->> 'month' in"
            sql += " (#{filters.to_s[1..-2].tr('"', "'")})"
          end
          sql
        end
      end

      def area_diversity_gbif_sql
        sql = <<-SQL
          SELECT taxonkey
          FROM external.gbif_occurrences
          JOIN research_project_sources
          ON research_project_sources.sourceable_id =
            external.gbif_occurrences.gbifid
          WHERE sourceable_type = 'GbifOccurrence'
          AND research_project_id = #{project.id}
        SQL

        if taxon_groups
          filters = selected_taxon_groups.to_s[1..-2].tr('"', "'")
          sql += " AND kingdom in (#{filters})"
        end

        if months
          filters = months.split('|')

          if filters.length == 1
            month = filters.first
            sql += if month == 'february'
                     ' AND month = 2'
                   else
                     ' AND month = 4'
                   end
          elsif filters.length > 1
            sql += ' AND (month = 2 OR month = 4)'
          end
        end
        sql
      end

      def area_diversity_cal_location(location)
        sql = area_diversity_cal_sql
        sql += " AND research_project_sources.metadata ->> 'location'"
        sql += " = '#{location}'"
        sql
      end

      def area_diversity_gbif_location(location)
        sql = area_diversity_gbif_sql
        sql += " AND research_project_sources.metadata ->> 'location'"
        sql += " = '#{location}'"
        sql
      end

      def months
        params['months']
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
# rubocop:enable Metrics/PerceivedComplexity
