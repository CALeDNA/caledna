# frozen_string_literal: true

require "administrate/base_dashboard"

class ResearchProjectDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    description: Field::Text,
    published: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    researcher_authors: ProjectAuthorField,
    user_authors: ProjectAuthorField,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
    :description,
    :published,
    :created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :name,
    :description,
    :published,
    :researcher_authors,
    :user_authors,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
    :published,
    :description,
    :researcher_authors,
    :user_authors,
  ].freeze


  def display_resource(research_project)
    "Research Project: #{research_project.name}"
  end
end
