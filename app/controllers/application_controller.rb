# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_raven_context

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

  private

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
