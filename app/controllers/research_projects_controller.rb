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

  def pillar_point
    if project.present?
      @inat_observations = inat_observations
      @samples = paginated_samples
      @project = project
      @asvs_count = asvs_count
      @stats = stats
      @occurences = occurences
    else
      @inat_observations = []
      @samples = []
      @project = nil
      @asvs_count = []
      @stats = []
      @occurences = []
    end
  end

  private

  def stats
    { inat_stats: inat_stats, cal_stats: cal_stats }
  end

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

  def occurences
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
    if params[:view]
      samples.page(params[:page])
    else
      samples
    end
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
