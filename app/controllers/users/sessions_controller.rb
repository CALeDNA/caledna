# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    layout 'river/application' if CheckWebsite.pour_site?

    def create
      super
      flash.delete(:notice)
    end

    def destroy
      super
      flash.delete(:notice)
    end

    def after_sign_in_path_for(_)
      root_path
    end

    def after_sign_out_path_for(_)
      root_path
    end
  end
end
