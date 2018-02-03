# frozen_string_literal: true

module Admin
  class ResearchersController < Admin::ApplicationController
    # NOTE: Changed the generated Administrate file. Let password be
    #  blank when editing.
    # https://github.com/thoughtbot/administrate/issues/495#issuecomment-249566344

    def show
      # NOTE: because adminstrate/pundit needs #show to display records
      # on the index page, the only way to prevent users from accessing
      # #show while making #index work, is to authorize edit/update/delete
      # on #show
      authorize requested_resource, :access_show?

      render locals: {
        page: Administrate::Page::Show.new(dashboard, requested_resource)
      }
    end

    def update
      if params[:researcher][:password].blank?
        params[:researcher].delete(:password)
        params[:researcher].delete(:password_confirmation)
      end
      super
    end
  end
end
