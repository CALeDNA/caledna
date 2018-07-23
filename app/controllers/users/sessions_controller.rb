# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def create
      super
      flash.delete(:notice)
    end

    def destroy
      super
      flash.delete(:notice)
    end

    def after_sign_in_path_for(resource)
      name = resource.username
      if Rails.env.staging?
        root_path
      else
        "#{ENV.fetch('CAL_BASE_URL')}/auth-page?name=#{name}"
      end
    end

    def after_sign_out_path_for(_)
      if Rails.env.staging?
        root_path
      else
        "#{ENV.fetch('CAL_BASE_URL')}/auth-page?name="
      end
    end
  end
end
