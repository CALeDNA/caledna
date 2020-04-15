# frozen_string_literal: true

class ResearchProjectsController < ApplicationController
  include CustomPagination

  def index
    @projects = projects
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
  def projects_sql
    <<-SQL
    SELECT research_projects.id, research_projects.name,
    research_projects.slug,
    COUNT(DISTINCT(samples.id))
    FROM research_projects
    LEFT JOIN research_project_sources
      ON research_projects.id = research_project_sources.research_project_id
      AND sourceable_type = 'Sample'
    LEFT JOIN samples
      ON research_project_sources.sourceable_id = samples.id
      AND samples.status_cd = 'results_completed'
      AND latitude IS NOT NULL
      AND longitude IS NOT NULL
    WHERE published = TRUE
    GROUP BY research_projects.id
    ORDER BY research_projects.name
    LIMIT $1 OFFSET $2;
    SQL
  end

  def projects
    @projects ||= begin
      bindings = [[nil, limit], [nil, offset]]
      raw_records = conn.exec_query(projects_sql, 'q', bindings)
      records = raw_records.map { |r| OpenStruct.new(r) }
      add_pagination_methods(records)
      records
    end
  end

  def count_sql
    <<-SQL
    SELECT COUNT(DISTINCT(research_projects.id))
    FROM research_projects
    JOIN research_project_sources
      ON research_projects.id = research_project_sources.research_project_id
    JOIN samples
      ON research_project_sources.sourceable_id = samples.id
    WHERE samples.status_cd = 'results_completed'
    AND latitude IS NOT NULL
    AND longitude IS NOT NULL
    AND sourceable_type = 'Sample';
    SQL
  end

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
