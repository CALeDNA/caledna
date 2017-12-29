require "administrate/base_dashboard"

class ProjectDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    samples: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    description: Field::Text,
    kobo_name: Field::String,
    kobo_id: Field::Number,
    kobo_payload: Field::String.with_options(searchable: false),
    start_date: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
    :samples,
    :start_date,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :name,
    :description,
    :kobo_name,
    :kobo_id,
    :start_date,
    :created_at,
    :updated_at,
    :kobo_payload,
    :samples,
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
    :description,
    :kobo_name,
    :kobo_id,
    :start_date,
    :samples,
  ].freeze

  def display_resource(project)
    project.name
  end
end
