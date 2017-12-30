require "administrate/base_dashboard"

class SampleDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    project: Field::BelongsTo.with_options(
      order: 'name asc', # order in form dropdown
      searchable: true, # make associated project name searchable
      searchable_field: 'name'
    ),
    id: Field::Number,
    latitude: Field::String.with_options(searchable: false),
    longitude: Field::String.with_options(searchable: false),
    collection_date: Field::DateTime,
    submission_date: Field::DateTime,
    kit_number: Field::String,
    location_letter: Field::String,
    site_number: Field::String,
    bar_code: Field::String,
    kobo_data: Field::JSON.with_options(searchable: false),
    approved: Field::Boolean,
    analyzed: Field::Boolean,
    analysis_date: Field::DateTime,
    notes: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :id,
    :project,
    :latitude,
    :longitude,
    :bar_code,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :project,
    :latitude,
    :longitude,
    :bar_code,
    :kit_number,
    :location_letter,
    :site_number,
    :approved,
    :analyzed,
    :notes,
    :collection_date,
    :submission_date,
    :analysis_date,
    :created_at,
    :updated_at,
    :kobo_data,
  ].freeze

  FORM_ATTRIBUTES = [
    :project,
    :latitude,
    :longitude,
    :bar_code,
    :kit_number,
    :location_letter,
    :site_number,
    :approved,
    :analyzed,
    :notes,
    :collection_date,
    :submission_date,
    :analysis_date,
  ].freeze

  def display_resource(sample)
    sample.bar_code
  end
end
