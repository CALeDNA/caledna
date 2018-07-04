# frozen_string_literal: true

module Admin
  class PagesController < Admin::ApplicationController
    require_relative './services/admin_text_editor'
    include AdminTextEditor

    def create
      super
      Rails.application.reload_routes!
    end

    def update
      super
      Rails.application.reload_routes!
    end

    def destroy
      super
      Rails.application.reload_routes!
    end

    layout :resolve_layout
  end
end
