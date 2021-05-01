# frozen_string_literal: true

class ResearchProjectsController < ApplicationController
  include CustomPagination
  include CheckWebsite
  include FilterSamples
  layout 'river/application' if CheckWebsite.pour_site?

  def index
    @projects = projects
    @taxa_count = Website.default_site.taxa_count
    @families_count = Website.default_site.families_count
    @samples_with_results_count = completed_samples_count
  end

  def show
    redirect_show if project&.show_pages?
    @project = project
  end

  private

  # =======================
  # index
  # =======================

  # NOTE: this query provides the samples count per project
  # rubocop:disable Metrics/MethodLength
  def projects_sql
    sql = <<-SQL
    SELECT research_projects.id, research_projects.name,
    research_projects.slug,
    COUNT(sourceable_id)
    FROM research_projects
    LEFT JOIN research_project_sources
      ON research_projects.id = research_project_sources.research_project_id
      AND sourceable_type = 'Sample'
      AND sourceable_id IN (SELECT DISTINCT sample_id FROM sample_primers)
    WHERE research_projects.published = TRUE
    SQL

    if CheckWebsite.pour_site?
      sql += " AND research_projects.id IN #{ResearchProject.la_river_ids}"
    end

    sql + <<-SQL
    GROUP BY research_projects.id
    ORDER BY research_projects.name
    LIMIT $1 OFFSET $2;
    SQL
  end
  # rubocop:enable Metrics/MethodLength

  def projects
    @projects ||= begin
      bindings = [[nil, limit], [nil, offset]]
      raw_records = conn.exec_query(projects_sql, 'q', bindings)
      records = raw_records.map { |r| OpenStruct.new(r) }
      add_pagination_methods(records)
      records
    end
  end

  # rubocop:disable Metrics/MethodLength
  def count_sql
    sql = <<-SQL
      SELECT count(DISTINCT research_projects.id)
      FROM research_projects
      JOIN research_project_sources
        ON research_projects.id = research_project_sources.research_project_id
        AND sourceable_type = 'Sample'
      WHERE research_projects.published = TRUE
      AND sourceable_id IN (SELECT DISTINCT sample_id FROM sample_primers)
    SQL

    if CheckWebsite.pour_site?
      sql += " AND research_projects.id IN #{ResearchProject.la_river_ids};"
    end
    sql
  end
  # rubocop:enable Metrics/MethodLength

  # =======================
  # show
  # =======================

  def redirect_show
    redirect_to research_project_page_url(
      research_project_id: project.slug, id: project.default_page.slug
    )
  end

  def project
    @project ||= ResearchProject.find_by(slug: params[:id])
  end
end
