# frozen_string_literal: true

class ResearchProjectsController < ApplicationController
  include PaginatedSamples
  include BatchData

  def index
    @projects = Kaminari.paginate_array(projects.to_a).page(params[:page])
  end

  def show
    redirect_show if project.show_pages?

    @project = project
    project_samples
  end

  def edit
    redirect_to research_projects_path unless current_researcher

    @page = page_with_section
  end

  def show_project_page
    @project = project
    @page = project_page
    la_river_view if project.name == 'Los Angeles River'
  end

  def pillar_point
    @page = page_with_section
    @project = project
    pillar_point_view
  end

  private

  def project_samples
    return [] unless params[:view] == 'list'
    @samples = project.present? ? paginated_samples : []
    @asvs_count = project.present? ? asvs_count : []
  end

  def redirect_show
    redirect_to research_project_page_url(
      research_project_id: project.slug, id: project.default_page.slug
    )
  end

  def page_with_section
    @page_with_section ||= begin
      id = params[:id]
      section = params[:section] || 'intro'
      Page.find_by(slug: "#{id}/#{section}")
    end
  end

  def project_page
    @project_page ||= begin
      page_id = params[:id]
      Page.where(research_project: project, slug: page_id).first
    end
  end

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def la_river_view
    @la_river_view ||= begin
      if params[:id] == 'overview'
        @division_counts = la_river_service.division_counts
        @division_counts_unique = la_river_service.division_counts_unique
      elsif params[:id] == 'sites'
        project_samples
      elsif params[:id] == 'identified-species'
        @identified_species_by_location =
          la_river_service.identified_species_by_location
      end

      render 'research_projects/la_river'
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def pillar_point_view
    if params[:section] == 'occurrence_comparison'
      @division_counts = pillar_point_service.division_counts
      @division_counts_unique = pillar_point_service.division_counts_unique
    elsif params[:section] == 'gbif_breakdown'
      @gbif_breakdown = pillar_point_service.gbif_breakdown
    elsif params[:section] == 'interactions'
      if params[:taxon]
        @interactions = pillar_point_service.globi_interactions
        @globi_target_taxon = pillar_point_service.globi_target_taxon
      else
        @taxon_list = pillar_point_service.globi_index
      end
    elsif params[:view] == 'list'
      @occurrences = occurrences
      @stats = pillar_point_service.stats
      @asvs_count = asvs_count
    elsif params[:section] == 'common_taxa'
      @taxon = params[:taxon]
      @gbif_taxa_with_edna_map = pillar_point_service.common_taxa_map
    elsif params[:section] == 'edna_gbif_comparison'
      @gbif_taxa = pillar_point_service.gbif_taxa
    elsif params[:section] == 'area_diversity'
    elsif params[:section] == 'detection_frequency'
    elsif params[:section] == 'source_comparison_all'
    elsif params[:section] == 'networks'
    else
      @stats = pillar_point_service.stats
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def project
    @project ||= ResearchProject.find_by(slug: project_slug)
  end

  def project_slug
    if params[:research_project_id]
      params[:research_project_id]
    else
      params[:id]
    end
  end

  # rubocop:disable Metrics/MethodLength
  def projects
    # NOTE: this query provides the samples count per project
    @projects ||= begin
      sql = 'SELECT research_projects.id, research_projects.name, ' \
      'research_projects.slug, ' \
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

      ActiveRecord::Base.connection.execute(sql)
    end
  end
  # rubocop:enable Metrics/MethodLength

  def samples
    @samples ||= Sample.approved.with_coordinates.order(:barcode)
                       .where(id: sample_ids)
  end

  def sample_ids
    @sample_ids ||= begin
      sql = 'SELECT sample_id ' \
        'FROM research_project_sources ' \
        'JOIN samples ' \
        'ON samples.id = research_project_sources.sample_id ' \
        'WHERE latitude IS NOT NULL AND longitude IS NOT NULL ' \
        "AND research_project_sources.research_project_id = #{project.id};"

      ActiveRecord::Base.connection.execute(sql).pluck('sample_id')
    end
  end

  def paginated_samples
    @paginated_samples ||= samples.page(params[:page])
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
    @occurrences ||= begin
      if params[:source] == 'gbif'
        pillar_point_service.gbif_occurrences.page(params[:page])
      else
        samples.page(params[:page])
      end
    end
  end

  def pillar_point_service
    @pillar_point_service ||= begin
      ResearchProjectService::PillarPoint.new(project, params)
    end
  end

  def la_river_service
    @la_river_service ||= begin
      ResearchProjectService::LaRiver.new(project, params)
    end
  end

  def query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    query
  end
end
