# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_raven_context

  def index; end

  protected

  # rubocop:disable Metrics/MethodLength
  def configure_permitted_parameters
    profile_attrs = %i[username email password password_confirmation]

    demographics_attrs = %i[
      name
      location
      age
      gender_cd
      education_cd
      ethnicity
      conservation_experience
      dna_experience
      work_info
      time_outdoors_cd
      occupation
      science_career_goals
      environmental_career_goals
      uc_affiliation
      uc_campus
      caledna_source
      agree
      can_contact
    ]

    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: profile_attrs + demographics_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: profile_attrs)
    devise_parameter_sanitizer.permit(:invite, keys: profile_attrs)
  end
  # rubocop:enable Metrics/MethodLength

  private

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
