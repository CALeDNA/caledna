# frozen_string_literal: true

module Admin
  class SiteNewsController < Admin::ApplicationController
    layout :resolve_layout

    private

    def scoped_resource
      resource_class.default_scoped.current_site
    end
  end
end
