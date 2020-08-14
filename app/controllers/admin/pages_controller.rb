# frozen_string_literal: true

module Admin
  class PagesController < Admin::ApplicationController
    layout :resolve_layout

    # NOTE: include index so I can use custom pagination params 'page_num'
    # Adminstrate uses 'page' for pagination, which breaks when using Page model

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def index
      search_term = params[:search].to_s.strip
      resources = Administrate::Search.new(scoped_resource,
                                           dashboard_class,
                                           search_term).run
      resources = apply_collection_includes(resources)
      resources = order.apply(resources)
      resources = resources.page(params[:page_num]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      render locals: {
        resources: resources,
        search_term: search_term,
        page: page,
        show_search_bar: show_search_bar?
      }
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    def apply_collection_includes(relation)
      resource_includes = []
      return relation if resource_includes.empty?
      relation.includes(*resource_includes)
    end

    def scoped_resource
      if current_researcher.superadmin?
        resource_class.default_scoped
      else
        resource_class.default_scoped.current_site
      end
    end
  end
end
