# frozen_string_literal: true

# NOTE: When page is created, a new route is also created.
# use Rails.application.reload_routes! so that app knows about the new routes.

module Admin
  class PagesController < Admin::ApplicationController
    require_relative './services/admin_text_editor'
    include AdminTextEditor

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

    # rubocop:disable Metrics/MethodLength
    def create
      create_params = resource_params.merge(website: Website::DEFAULT_SITE)

      resource = resource_class.new(create_params)
      authorize_resource(resource)

      if resource.save
        redirect_to(
          [namespace, resource],
          notice: translate_with_resource('create.success')
        )
      else
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, resource)
        }
      end

      Rails.application.reload_routes!
    end
    # rubocop:enable Metrics/MethodLength

    def update
      super
      Rails.application.reload_routes!
    end

    def destroy
      super
      Rails.application.reload_routes!
    end

    layout :resolve_layout

    private

    def apply_collection_includes(relation)
      resource_includes = []
      return relation if resource_includes.empty?
      relation.includes(*resource_includes)
    end
  end
end
