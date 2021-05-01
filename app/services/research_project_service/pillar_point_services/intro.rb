# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
module ResearchProjectService
  module PillarPointServices
    module Intro
      def stats
        { gbif_stats: gbif_stats, cal_stats: cal_stats }
      end

      private

      def gbif_stats
        observations = gbif_occurrences.count
        unique_organisms =
          PpGbifOccurrence
          .select('DISTINCT(taxonkey)')
          .joins(:research_project_sources)
          .where(
            "research_project_sources.sourceable_type = 'PpGbifOccurrence'"
          )
          .where("metadata ->> 'location' != 'Montara SMR'")
          .where('kingdom is not null')
          .where('research_project_sources.research_project_id = ?', project.id)
          .count

        {
          occurrences: observations,
          organisms: unique_organisms
        }
      end

      def cal_stats
        samples =
          ResearchProjectSource.cal.where(research_project: project).count
        {
          occurrences: samples,
          organisms: unique_organisms
        }
      end

      def unique_organisms
        sql = <<-SQL
        SELECT COUNT(DISTINCT(taxon_id))
        FROM pillar_point.asvs as pp_asvs
        WHERE pp_asvs.research_project_id = #{project.id}
        SQL

        query_results(sql).first['count']
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
