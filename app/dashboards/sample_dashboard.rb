# frozen_string_literal: true

require "administrate/base_dashboard"

class SampleDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    field_project: Field::BelongsTo.with_options(
      order: 'name asc', # order in form dropdown
      searchable: true, # make associated project name searchable
      searchable_field: 'name'
    ),
    photos: Field::HasMany,
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
    status_cd: Field::String,
    substrate_cd: Field::String,
    ecosystem_category_cd: Field::String,
    alt_id: Field::String,
    altitude: Field::String.with_options(searchable: false),
    gps_precision: Field::Number,
    location: Field::String,
    elevatr_altitude: Field::String.with_options(searchable: false),
    director_notes: Field::Text,
    habitat: Field::String,
    depth: Field::String,
    environmental_features: Field::String,
    environmental_settings: Field::String,
    missing_coordinates: Field::Boolean,
    metadata: Field::String.with_options(searchable: false),
    primers: Field::String,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :barcode,
    :latitude,
    :longitude,
    :status_cd,
    :field_project,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
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
    :ecosystem_category_cd,
    :field_notes,
    :director_notes,
    :submission_date,
    :collection_date,
    :habitat,
    :depth,
    :environmental_features,
    :environmental_settings,
    :primers,
    :photos,
    :metadata,
    :kobo_data
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
    :ecosystem_category_cd,
    :field_notes,
    :director_notes,
    :submission_date,
    :collection_date,
    :habitat,
    :depth,
    :environmental_features,
    :environmental_settings,
    :primers,
    :photos,
    :metadata,
  ].freeze

  def display_resource(sample)
    sample.barcode
  end
end
