# frozen_string_literal: true

require 'administrate/base_dashboard'

class SurveyAnswerDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    survey_response: Field::BelongsTo,
    id: Field::Number,
    survey_question_id: Field::Number,
    content: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :survey_response,
    :id,
    :survey_question_id,
    :content,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :survey_response,
    :id,
    :survey_question_id,
    :content,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :survey_response,
    :survey_question_id,
    :content,
  ].freeze

  # def display_resource(survey_answer)
  #   "SurveyAnswer ##{survey_answer.id}"
  # end
end
