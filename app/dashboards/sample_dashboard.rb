require "administrate/base_dashboard"

class SampleDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    photos: Field::HasMany,
    pg_search_document: Field::HasOne,
    field_data_project: Field::BelongsTo.with_options(
      order: 'name asc', # order in form dropdown
      searchable: true, # make associated project name searchable
      searchable_field: 'name'
    ),
    id: Field::Number,
    kobo_id: Field::Number,
    latitude: Field::Number.with_options(searchable: false),
    longitude: Field::Number.with_options(searchable: false),
    altitude: Field::Number.with_options(searchable: false),
    gps_precision: Field::Number.with_options(searchable: false),
    collection_date: Field::DateTime,
    submission_date: Field::DateTime,
    barcode: Field::String,
    kobo_data: Field::JSON.with_options(searchable: false),
    notes: Field::Text,
    location: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    status_cd: EnumField,
    substrate_cd: EnumField,
    ecosystem_category_cd: EnumField,
    alt_id: Field::String,
    processor_id: Field::Number,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :barcode,
    :latitude,
    :longitude,
    :field_data_project,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :barcode,
    :latitude,
    :longitude,
    :altitude,
    :gps_precision,
    :field_data_project,
    :location,
    :status_cd,
    :substrate_cd,
    :ecosystem_category_cd,
    :alt_id,
    :notes,
    :photos,
    :submission_date,
    :collection_date,
    :kobo_data,
  ].freeze

  FORM_ATTRIBUTES = [
    :barcode,
    :latitude,
    :longitude,
    :altitude,
    :gps_precision,
    :field_data_project,
    :location,
    :status_cd,
    :substrate_cd,
    :ecosystem_category_cd,
    :alt_id,
    :notes,
    :photos,
    :submission_date,
    :collection_date,
  ].freeze

  def display_resource(sample)
    sample.barcode
  end
end
