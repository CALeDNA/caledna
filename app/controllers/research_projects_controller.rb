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
    return unless current_researcher
    @project = project
    researcher_view
  end

  private

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  # rubocop:disable Metrics/AbcSize
  def researcher_view
    if params[:section] == 'occurrence_comparsion'
      @division_counts = project_service.division_counts
      @division_counts_unique = project_service.division_counts_unique
    elsif params[:section] == 'gbif_breakdown'
      @gbif_breakdown = project_service.gbif_breakdown
    elsif params[:section] == 'interactions'
      @interactions = project_service.globi_interactions
      @globi_target_taxon = project_service.globi_target_taxon
      @globi_requests = GlobiRequest.all
    elsif params[:view] == 'list'
      @occurrences = occurrences
      @stats = project_service.stats
      @asvs_count = asvs_count
    elsif params[:section] == 'edna_gbif_comparison'
      @gbif_taxa = project_service.gbif_taxa
      @gbif_taxa_with_edna = project_service.gbif_taxa_with_edna
    else
      @stats = project_service.stats
    end
  end
  # rubocop:enable Metrics/AbcSize

  def project
    @project ||= begin
      where_sql = params[:id].to_i.zero? ? 'slug = ?' : 'id = ?'
      ResearchProject.where(where_sql, params[:id]).first
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
    "WHERE samples.status_cd != 'processed_invalid_sample' " \
    'AND latitude IS NOT NULL AND longitude IS NOT NULL ' \
    'GROUP BY research_projects.id ' \
    'ORDER BY research_projects.name;'

    @projects ||= ActiveRecord::Base.connection.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength

  def samples
    Sample.approved.with_coordinates.order(:barcode)
          .where(id: sample_ids)
  end

  def sample_ids
    sql = 'SELECT sample_id ' \
      'FROM research_project_sources ' \
      'JOIN samples ' \
      'ON samples.id = research_project_sources.sample_id ' \
      'WHERE latitude IS NOT NULL AND longitude IS NOT NULL ' \
      "AND research_project_sources.research_project_id = #{project.id};"

    @sample_ids ||= ActiveRecord::Base.connection.execute(sql)
                                      .pluck('sample_id')
  end

  def paginated_samples
    samples.page(params[:page])
  end

  def extraction_ids
    @extraction_ids ||= ResearchProjectSource
                        .where(
                          research_project_id: params[:id],
                          sourceable: Extraction
                        )
                        .pluck(:sourceable_id)
  end

  def occurrences
    if params[:source] == 'gbif'
      project_service.gbif_occurrences.page(params[:page])
    else
      samples.page(params[:page])
    end
  end

  def project_service
    @project_service ||= begin
      ResearchProjectService::PillarPoint.new(project, params)
    end
  end

  def query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    query
  end
end
