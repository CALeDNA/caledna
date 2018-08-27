# frozen_string_literal: true

module ResearchProjectService
  class PillarPoint
    attr_reader :project

    def initialize(project)
      @project = project
    end

    def conn
      @conn ||= ActiveRecord::Base.connection
    end

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

    def stats
      { gbif_stats: gbif_stats, cal_stats: cal_stats }
    end

    def convert_counts(results)
      counts = {}
      results.to_a.map do |result|
        counts[result['category']] = result['count']
      end
      counts
    end

    # rubocop:disable Metrics/MethodLength
    def gbif_division_stats
      sql = <<-SQL
        SELECT  kingdom as category, count(kingdom)
        FROM external.gbif_occurrences
        JOIN research_project_sources
        ON research_project_sources.sourceable_id =
          external.gbif_occurrences.gbifid
        WHERE (research_project_sources.sourceable_type = 'GbifOccurrence')
      SQL

      sql += 'AND (research_project_sources.research_project_id = ' \
        "#{conn.quote(project.id)}) " \
        'GROUP BY kingdom'

      conn.execute(sql)
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def gbif_division_unique_stats
      # and basisofrecord = 'PRESERVED_SPECIMEN'

      sql = <<-SQL
        SELECT kingdom as category, count(specieskey) FROM (
          SELECT  distinct(specieskey), kingdom
          FROM external.gbif_occurrences
          JOIN research_project_sources
          ON research_project_sources.sourceable_id =
            external.gbif_occurrences.gbifid
          WHERE (research_project_sources.sourceable_type = 'GbifOccurrence')
        SQL

      sql += 'AND (research_project_sources.research_project_id =  ' \
        "#{conn.quote(project.id)}) "

      sql += <<-SQL
          ORDER BY kingdom
        ) AS foo
        GROUP BY kingdom;
      SQL

      conn.execute(sql)
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
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
      SQL

      sql += 'AND (research_project_sources.research_project_id = ' \
        "#{conn.quote(project.id)})"

      sql += <<-SQL
        GROUP BY name
        ORDER BY name;
      SQL

      conn.execute(sql)
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def cal_division_unique_stats
      sql = <<-SQL
        SELECT name as category, count("taxonID") FROM (
        SELECT distinct("taxonID"), name
        FROM "asvs"
        JOIN "ncbi_nodes" ON "ncbi_nodes"."taxon_id" = "asvs"."taxonID"
        JOIN "ncbi_divisions" ON "ncbi_divisions"."id" = "ncbi_nodes"."cal_division_id"
        JOIN research_project_sources ON sourceable_id = extraction_id
        WHERE (research_project_sources.sourceable_type = 'Extraction')
      SQL
      sql += 'AND (research_project_sources.research_project_id = ' \
        "#{conn.quote(project.id)})"

      sql += <<-SQL
        ORDER BY name
        ) AS foo
        GROUP BY name;
      SQL

      conn.execute(sql)
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def gbif_stats
      observations = gbif_occurrences.count
      unique_organisms =
        GbifOccurrence
        .select('DISTINCT(specieskey)')
        .joins(:research_project_sources)
        .where("research_project_sources.sourceable_type = 'GbifOccurrence'")
        .where('research_project_sources.research_project_id = ?', project.id)
        .count

      {
        occurrences: observations,
        organisms: unique_organisms
      }
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def cal_stats
      samples = ResearchProjectSource.cal.where(research_project: project).count
      unique_organisms =
        Asv
        .select('DISTINCT("taxonID")')
        .joins('JOIN research_project_sources ON sourceable_id = extraction_id')
        .where("research_project_sources.sourceable_type = 'Extraction'")
        .where('research_project_sources.research_project_id = ?', project.id)
        .count

      {
        occurrences: samples,
        organisms: unique_organisms
      }
    end
    # rubocop:enable Metrics/MethodLength

    def gbif_occurrences
      ids =
        ResearchProjectSource
        .gbif
        .where(research_project: project)
        .where("metadata ->> 'location' != 'Montara SMR'")
        .pluck(:sourceable_id)

      GbifOccurrence.where(gbifid: ids)
    end
  end
end
