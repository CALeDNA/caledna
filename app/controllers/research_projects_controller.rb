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
    @samples = samples
    @asvs_count = counts
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
    JOIN research_project_sources
      ON research_projects.id =
    research_project_sources.research_project_id
    JOIN samples
      ON research_project_sources.sample_id = samples.id
    WHERE samples.status_cd = 'results_completed'
    AND latitude IS NOT NULL
    AND longitude IS NOT NULL
    GROUP BY research_projects.id
    ORDER BY research_projects.name;
    SQL
  end

  def projects
    @projects ||= begin
      records = ActiveRecord::Base.connection.exec_query(projects_sql)
      records.map { |r| OpenStruct.new(r) }
    end
  end

  # =======================
  # show
  # =======================

  def redirect_show
    redirect_to research_project_page_url(
      research_project_id: project.slug, id: project.default_page.slug
    )
  end

  def counts
    @counts ||= list_view? ? asvs_count : []
  end

  def samples
    @samples ||=
      list_view? ? research_project_paginated_samples(project.id) : []
  end

  def project
    @project ||= ResearchProject.find_by(slug: params[:id])
  end
end
