# frozen_string_literal: true

module PaginatedSamples
  extend ActiveSupport::Concern

  private

  def all_samples(query_string: {})
    Sample.la_river.approved.with_coordinates
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
  # sample searches
  # =======================

  def search_paginated_samples(query)
    @search_paginated_samples ||= begin
      ids = multisearch_ids(query)
      paginated_samples(query_string: { id: ids })
    end
  end

  def search_samples(query)
    @search_samples ||= begin
      ids = multisearch_ids(query)
      all_samples(query_string: { id: ids })
    end
  end

  def multisearch_ids(query)
    @multisearch_ids ||= PgSearch.multisearch(query).pluck(:searchable_id)
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
      Sample.results_completed.with_coordinates.order(:created_at)
            .joins('JOIN research_project_sources ' \
              'ON samples.id = research_project_sources.sourceable_id')
            .where('research_project_sources.research_project_id = ?',
                   project_id)
            .where("research_project_sources.sourceable_type = 'Sample'")
    end
  end
end
