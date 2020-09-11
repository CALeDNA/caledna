# frozen_string_literal: true

class ProfilesController < ApplicationController
  layout 'river/application' if CheckWebsite.pour_site?

  def show
    if current_user
      @user = current_user
    else
      redirect_to new_user_session_path
    end
  end
end
