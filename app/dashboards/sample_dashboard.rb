# frozen_string_literal: true

require "administrate/base_dashboard"

class SampleDashboard < Administrate::BaseDashboard
  ARRAY_FIELDS = %i[primers environmental_features environmental_settings]

  ATTRIBUTE_TYPES = {
    pg_search_document: Field::HasOne,
    field_project: Field::BelongsTo.with_options(
      order: 'name asc', # order in form dropdown
      searchable: true, # make associated project name searchable
      searchable_field: 'name'
    ),
    kobo_photos: Field::HasMany,
    asvs: Field::HasMany,
    research_project_sources: Field::HasMany,
    research_projects: Field::HasMany,
    id: Field::Number,
    kobo_id: Field::Number,
    latitude: Field::String.with_options(searchable: false),
    longitude: Field::String.with_options(searchable: false),
    submission_date: Field::DateTime,
    barcode: Field::String,
    kobo_data: Field::String.with_options(searchable: false),
    field_notes: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    collection_date: Field::DateTime,
    status_cd: EnumField.with_options(searchable: true),
    substrate_cd: EnumField,
    altitude: Field::String.with_options(searchable: false),
    gps_precision: Field::Number,
    location: Field::String,
    director_notes: Field::Text,
    habitat: EnumField,
    depth: EnumField,
    environmental_features: ArrayField,
    environmental_settings: ArrayField,
    missing_coordinates: Field::Boolean,
    metadata: Field::String.with_options(searchable: false),
    csv_data: Field::String.with_options(searchable: false),
    country: Field::String,
    country_code: Field::String,
    has_permit: Field::Boolean,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :barcode,
    :status_cd,
    :field_project,
    :updated_at,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :barcode,
    :latitude,
    :longitude,
    :altitude,
    :gps_precision,
    :field_project,
    :research_projects,
    :location,
    :status_cd,
    :substrate_cd,
    :field_notes,
    :director_notes,
    :submission_date,
    :collection_date,
    :habitat,
    :depth,
    :environmental_features,
    :environmental_settings,
    :kobo_photos,
    :country,
    :country_code,
    :has_permit,
    :kobo_id,
    :created_at,
    :updated_at,
    :metadata,
    :kobo_data,
    :csv_data,
  ].freeze

  FORM_ATTRIBUTES = [
    :barcode,
    :latitude,
    :longitude,
    :altitude,
    :gps_precision,
    :field_project,
    :research_projects,
    :location,
    :status_cd,
    :substrate_cd,
    :field_notes,
    :director_notes,
    :submission_date,
    :collection_date,
    :habitat,
    :depth,
    :environmental_features,
    :environmental_settings,
    :kobo_photos,
    :country,
    :country_code,
    :has_permit
  ].freeze

  def display_resource(sample)
    sample.barcode
  end

  def permitted_attributes
    super + ARRAY_FIELDS.map { |f| { f => []} }
  end
end
