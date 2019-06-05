# frozen_string_literal: true

require "administrate/base_dashboard"

class FieldDataProjectDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    samples: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    description: Field::Text,
    kobo_id: Field::Number,
    kobo_payload: Field::JSON.with_options(searchable: false),
    date_range: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    last_import_date: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
    :samples,
    :last_import_date,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :name,
    :description,
    :kobo_id,
    :created_at,
    :updated_at,
    :last_import_date,
    :kobo_payload,
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
    :description,
    :kobo_id,
  ].freeze

  def display_resource(project)
    project.name
  end
end
