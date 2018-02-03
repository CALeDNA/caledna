require "administrate/base_dashboard"

class SampleDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    photos: Field::HasMany,
    pg_search_document: Field::HasOne,
    project: Field::BelongsTo.with_options(
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
    bar_code: Field::String,
    kobo_data: Field::JSON.with_options(searchable: false),
    analysis_date: Field::DateTime,
    notes: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    results_completion_date: Field::DateTime,
    status_cd: EnumField,
    processor_id: Field::Number,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :project,
    :latitude,
    :longitude,
    :bar_code,
    :processor,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :project,
    :latitude,
    :longitude,
    :bar_code,
    :processor,
    :kobo_id,
    :status_cd,
    :notes,
    :photos,
    :submission_date,
    :collection_date,
    :analysis_date,
    :results_completion_date,
    :created_at,
    :updated_at,
    :kobo_data,
  ].freeze

  FORM_ATTRIBUTES = [
    :project,
    :latitude,
    :longitude,
    :bar_code,
    :processor,
    :kobo_id,
    :status_cd,
    :notes,
    :submission_date,
    :collection_date,
    :analysis_date,
    :results_completion_date,
    :created_at,
    :updated_at,
  ].freeze

  def display_resource(sample)
    sample.bar_code
  end
end
