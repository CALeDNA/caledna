# frozen_string_literal: true

require "administrate/base_dashboard"

class FieldProjectDashboard < Administrate::BaseDashboard
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
    published: Field::Boolean,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
    :samples,
    :last_import_date,
    :published,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :name,
    :description,
    :kobo_id,
    :created_at,
    :updated_at,
    :last_import_date,
    :kobo_payload,
    :published,
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
    :description,
    :kobo_id,
    :published,
  ].freeze

  def display_resource(project)
    project.name
  end
end
