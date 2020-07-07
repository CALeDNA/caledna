require "administrate/base_dashboard"

class EventDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    field_project: Field::BelongsTo,
    flyer: ActiveStorageAttachmentField,
    id: Field::Number,
    name: Field::String,
    start_date: Field::DateTime,
    end_date: Field::DateTime,
    description: TextEditorField,
    location: Field::Text,
    contact: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    event_registrations: Field::HasMany,
    registration_required: Field::Boolean,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
    :event_registrations,
    :start_date,
    :updated_at
  ].freeze

   SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :registration_required,
    :start_date,
    :end_date,
    :description,
    :location,
    :contact,
    :field_project,
    :flyer,
    :created_at,
    :updated_at,
    :event_registrations
  ].freeze


  FORM_ATTRIBUTES = [
    :name,
    :registration_required,
    :start_date,
    :end_date,
    :description,
    :location,
    :contact,
    :field_project,
    :flyer
  ].freeze

  def display_resource(event)
    event.name
  end

  def permitted_attributes
    super + [:flyer]
  end
end
