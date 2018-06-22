require "administrate/base_dashboard"

class EventDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    field_data_project: Field::BelongsTo,
    id: Field::Number,
    name: Field::String,
    start_date: Field::DateTime,
    end_date: Field::DateTime,
    description: Field::Text,
    location: Field::Text,
    contact: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
    :start_date,
  ].freeze

   SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :start_date,
    :end_date,
    :description,
    :location,
    :contact,
    :field_data_project,
    :created_at,
    :updated_at,
  ].freeze


  FORM_ATTRIBUTES = [
    :name,
    :start_date,
    :end_date,
    :description,
    :location,
    :contact,
    :field_data_project,
  ].freeze

  def display_resource(event)
    event.name
  end
end
