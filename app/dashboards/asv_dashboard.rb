require "administrate/base_dashboard"

class AsvDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    research_project: Field::BelongsTo.with_options(
      searchable: true,
      searchable_field: 'name',
    ),
    sample: Field::BelongsTo.with_options(
      searchable: true,
      searchable_field: 'barcode',
    ),
    ncbi_node: Field::BelongsTo.with_options(
      searchable: true,
      searchable_field: 'canonical_name',
    ),
    id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    taxon_id: Field::Number,
    primer: Field::BelongsTo.with_options(
      searchable: true,
      searchable_field: 'name',
    ),
    count: Field::Number
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :sample,
    :ncbi_node,
    :research_project,
    :primer,
    :count,
    :updated_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :sample,
    :ncbi_node,
    :taxon_id,
    :research_project,
    :primer,
    :count,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :sample,
    :taxon_id,
    :research_project,
    :primer,
    :count,
  ].freeze

  # Overwrite this method to customize how asvs are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(asv)
    "#{asv.sample.barcode} - #{asv.ncbi_node.canonical_name}"
  end
end
