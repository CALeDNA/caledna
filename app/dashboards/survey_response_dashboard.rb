# frozen_string_literal: true

require 'administrate/base_dashboard'

class SurveyResponseDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    survey: Field::BelongsTo,
    survey_answers: Field::HasMany,
    id: Field::Number,
    user_id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :survey,
    :survey_answers,
    :id,
    :user_id,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :survey,
    :survey_answers,
    :id,
    :user_id,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :survey,
    :survey_answers,
    :user_id,
  ].freeze

  # def display_resource(survey_response)
  #   "SurveyResponse ##{survey_response.id}"
  # end
end
