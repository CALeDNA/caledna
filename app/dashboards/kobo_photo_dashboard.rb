# frozen_string_literal: true

require "administrate/base_dashboard"

class KoboPhotoDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    sample: Field::BelongsTo,
    id: Field::Number,
    source_url: Field::Image,
    file_name: Field::String,
    kobo_payload: Field::JSON.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    photo: ActiveStorageAttachmentField,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :sample,
    :photo,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :sample,
    :file_name,
    :photo,
    :kobo_payload,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
  ].freeze

  def permitted_attributes
    super + [:photo]
  end

  def display_resource(resource)
    "Photo ##{resource.id}"
  end
end
