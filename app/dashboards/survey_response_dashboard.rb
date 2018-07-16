# frozen_string_literal: true

require 'administrate/base_dashboard'

class SurveyResponseDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    survey: Field::BelongsTo,
    survey_answers: Field::HasMany,
    user: Field::BelongsTo,
    id: Field::Number,
    total_score: Field::Number,
    passed: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :survey,
    :user,
    :total_score,
    :passed,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :survey,
    :user,
    :total_score,
    :passed,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :survey,
    :user,
    :total_score,
    :passed,
  ].freeze

  def display_resource(survey_response)
    "Result ##{survey_response.id}"
  end
end
