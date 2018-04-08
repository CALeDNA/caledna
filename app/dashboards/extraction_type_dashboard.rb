# frozen_string_literal: true

require "administrate/base_dashboard"

class ExtractionTypeDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    extractions: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
    :extractions,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :name,
    :extractions,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
  ].freeze

  def display_resource(extraction_type)
    extraction_type.name
  end
end
