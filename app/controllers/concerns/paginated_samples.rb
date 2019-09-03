# frozen_string_literal: true

module PaginatedSamples
  extend ActiveSupport::Concern

  private

  def all_samples(query_string: {})
    Sample.approved.with_coordinates
          .order(:created_at)
          .where(query_string)
  end

  def paginated_samples(query_string: {})
    all_samples(query_string: query_string).page(page)
  end

  def list_view?
    params[:view] == 'list'
  end

  def page
    params[:page]
  end

  # =======================
  # field data projects
  # =======================

  def field_data_project_samples
    all_samples(query_string: field_data_project_query_string)
  end

  def field_data_project_paginated_samples
    paginated_samples(query_string: field_data_project_query_string)
  end

  def field_data_project_query_string
    query = {}
    query[:status_cd] = params[:status] if params[:status]
    query[:field_data_project_id] = params[:id]
    query
  end

  # =======================
  # research projects
  # =======================

  def research_project_paginated_samples(project_id)
    @research_project_paginated_samples ||= begin
      research_project_samples(project_id).page(page)
    end
  end

  def research_project_samples(project_id)
    @research_project_samples ||= begin
      Sample.approved.with_coordinates.order(:created_at)
            .joins('JOIN research_project_sources ' \
              'ON samples.id = research_project_sources.sample_id')
            .where('research_project_sources.research_project_id = ?',
                   project_id)
    end
  end
end
