# frozen_string_literal: true

require "administrate/base_dashboard"

class PhotoDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    sample: Field::BelongsTo,
    id: Field::Number,
    source_url: ImageField,
    file_name: Field::String,
    kobo_payload: Field::JSON.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :sample,
    :file_name,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :sample,
    :file_name,
    :source_url,
    :kobo_payload,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
  ].freeze

  def display_resource(photo)
    "Photo ##{photo.id}"
  end
end
