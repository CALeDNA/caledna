# frozen_string_literal: true

# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    require_relative './services/admin_text_editor'
    include AdminTextEditor

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    before_action :authenticate_researcher!
    include Administrate::Punditize

    def pundit_user
      current_researcher
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end

    private

    def user_not_authorized(_exception)
      flash[:error] = t(:default, scope: 'pundit')
      redirect_to(request.referrer || admin_samples_path)
    end
  end
end
