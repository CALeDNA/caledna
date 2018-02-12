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
    processor: Field::BelongsTo.with_options(class_name: "Researcher"),
    id: Field::Number,
    kobo_id: Field::Number,
    latitude: Field::String.with_options(searchable: false),
    longitude: Field::String.with_options(searchable: false),
    collection_date: Field::DateTime,
    submission_date: Field::DateTime,
    barcode: Field::String,
    kobo_data: Field::JSON.with_options(searchable: false),
    notes: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    status_cd: EnumField,
    substrate_cd: EnumField,
    ecosystem_category_cd: EnumField,
    alt_id: Field::String,
    processor_id: Field::Number,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :field_data_project,
    :latitude,
    :longitude,
    :barcode,
    :processor,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :field_data_project,
    :latitude,
    :longitude,
    :barcode,
    :processor,
    :kobo_id,
    :status_cd,
    :substrate_cd,
    :ecosystem_category_cd,
    :alt_id,
    :notes,
    :photos,
    :submission_date,
    :collection_date,
    :created_at,
    :updated_at,
    :kobo_data,
  ].freeze

  FORM_ATTRIBUTES = [
    :field_data_project,
    :latitude,
    :longitude,
    :barcode,
    :processor,
    :kobo_id,
    :status_cd,
    :substrate_cd,
    :ecosystem_category_cd,
    :alt_id,
    :notes,
    :submission_date,
    :collection_date,
    :created_at,
    :updated_at,
  ].freeze

  def display_resource(sample)
    sample.barcode
  end
end
