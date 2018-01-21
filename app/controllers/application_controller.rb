# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def index; end

  protected

  def configure_permitted_parameters
    allowed_params = [
      :username
    ]

    devise_parameter_sanitizer.permit(:sign_up, keys: allowed_params)
    devise_parameter_sanitizer.permit(:account_update, keys: allowed_params)
    devise_parameter_sanitizer.permit(:invite, keys: allowed_params)
  end
end