# frozen_string_literal: true

require 'administrate/base_dashboard'

class SurveyQuestionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    survey: Field::BelongsTo,
    survey_options: Field::NestedHasMany.with_options(skip: :survey_question),
    id: Field::Number,
    order_number: Field::Number,
    content: Field::Text,
    type_cd: EnumField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :survey,
    :content,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :survey,
    :order_number,
    :content,
    :type_cd,
    :survey_options,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :content,
    :order_number,
    :type_cd,
    :survey_options,
  ].freeze

  # def display_resource(survey_question)
  #   "SurveyQuestion ##{survey_question.id}"
  # end
end
