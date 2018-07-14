# frozen_string_literal: true

require 'administrate/base_dashboard'

class SurveyDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    survey_questions: Field::NestedHasMany.with_options(skip: :survey),
    id: Field::Number,
    name: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    slug: Field::String,
    description: Field::Text,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
    :created_at,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :name,
    :slug,
    :description,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
    :slug,
    :description,
    :survey_questions,
  ].freeze

  def display_resource(survey)
    survey.name
  end
end
