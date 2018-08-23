# frozen_string_literal: true

class ResearchProjectsController < ApplicationController
  include PaginatedSamples
  include BatchData

  def index
    @projects = Kaminari.paginate_array(projects.to_a).page(params[:page])
  end

  def show
    @samples = project.present? ? paginated_samples : []
    @project = project
    @asvs_count = project.present? ? asvs_count : []
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def pillar_point
    if project.present?
      @project = project

      if params[:section] == 'organisms'
        @division_counts = division_counts
        @division_counts_unique = division_counts_unique
      elsif params[:view] == 'list'
        @occurrences = occurrences
        @stats = stats
        @asvs_count = asvs_count
      else
        @samples = samples
        @stats = stats
        @inat_observations = inat_observations
        @asvs_count = asvs_count
      end
    else
      blank_page
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  private

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def blank_page
    @inat_observations = []
    @samples = []
    @project = nil
    @asvs_count = []
    @stats = []
    @occurrences = []
  end

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

  def stats
    { inat_stats: inat_stats, cal_stats: cal_stats }
  end

  def convert_counts(results)
    counts = {}
    results.to_a.map do |result|
      counts[result['category']] = result['count']
    end
    counts
  end

  # rubocop:disable Metrics/MethodLength
  def inat_division_stats
    sql = <<-SQL
      SELECT  kingdom as category, count("taxonID")
      FROM "inat_observations"
      JOIN "research_project_sources"
      ON "research_project_sources"."sourceable_id" = "inat_observations"."id"
      AND "research_project_sources"."sourceable_type" = 'InatObservation'
      WHERE (research_project_sources.sourceable_type = 'InatObservation')
    SQL

    sql += 'AND (research_project_sources.research_project_id = ' \
      "#{conn.quote(project.id)}) " \
      'GROUP BY kingdom'

    conn.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def inat_division_unique_stats
    sql = <<-SQL
      SELECT kingdom as category, count("taxonID") FROM (
        SELECT  distinct("taxonID"), kingdom
        FROM "inat_observations"
        JOIN "research_project_sources"
        ON "research_project_sources"."sourceable_id" = "inat_observations"."id"
        AND "research_project_sources"."sourceable_type" = 'InatObservation'
        WHERE (research_project_sources.sourceable_type = 'InatObservation')
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
  def inat_stats
    observations = inat_observations.count
    unique_organisms =
      InatObservation
      .select('DISTINCT("taxonID")')
      .joins(:research_project_sources)
      .where("research_project_sources.sourceable_type = 'InatObservation'")
      .where('research_project_sources.research_project_id = ?', project.id)
      .count

    {
      occurences: observations,
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
      occurences: samples,
      organisms: unique_organisms
    }
  end
  # rubocop:enable Metrics/MethodLength

  def inat_observations
    ids = ResearchProjectSource.inat.where(research_project: project)
                               .pluck(:sourceable_id)

    InatObservation.where(id: ids)
  end

  def occurrences
    if params[:source] == 'inat'
      paginated_inat_observations
    else
      paginated_samples
    end
  end

  def project
    @project ||= begin
      where_sql = params[:id].to_i.zero? ? 'slug = ?' : 'id = ?'

      if current_researcher
        ResearchProject.where(where_sql, params[:id]).first
      else
        ResearchProject.where(where_sql, params[:id])
                       .where(published: true)
                       .first
      end
    end
  end

  # rubocop:disable Metrics/MethodLength
  def projects
    # NOTE: this query provides the samples count per project
    sql = 'SELECT research_projects.id, research_projects.name, ' \
    'COUNT(DISTINCT(samples.id)) ' \
    'FROM research_projects ' \
    'JOIN research_project_sources ' \
    'ON research_projects.id = ' \
    'research_project_sources.research_project_id ' \
    'JOIN samples ' \
    'ON research_project_sources.sample_id = samples.id ' \
    "WHERE samples.status_cd != 'processed_invalid_sample' "

    unless current_researcher.present?
      sql += 'AND research_projects.published = true ' \
    end

    sql += 'GROUP BY research_projects.id ' \
    'ORDER BY research_projects.name;'

    @projects ||= ActiveRecord::Base.connection.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength

  def samples
    Sample.approved.order(:barcode)
          .where(id: sample_ids)
  end

  def paginated_samples
    samples.page(params[:page])
  end

  def paginated_inat_observations
    if params[:view]
      Kaminari.paginate_array(inat_observations).page(params[:page])
    else
      inat_observations
    end
  end

  def sample_ids
    sql = 'SELECT sample_id ' \
      'FROM research_project_sources ' \
      'JOIN samples ' \
      'ON samples.id = research_project_sources.sample_id ' \
      "WHERE research_project_sources.research_project_id = #{project.id};"

    @sample_ids ||= ActiveRecord::Base.connection.execute(sql)
                                      .pluck('sample_id')
  end

  def extraction_ids
    @extraction_ids ||= ResearchProjectSource
                        .where(
                          research_project_id: params[:id],
                          sourceable: Extraction
                        )
                        .pluck(:sourceable_id)
  end

  def query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    query
  end
end
