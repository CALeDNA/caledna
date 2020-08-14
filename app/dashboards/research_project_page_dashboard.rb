require "administrate/base_dashboard"

class ResearchProjectPageDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    research_project: Field::BelongsTo.with_options(
      searchable: true,
      searchable_field: 'name'
    ),
    id: Field::Number,
    title: Field::String,
    body: TextEditorField,
    published: Field::Boolean,
    slug: Field::String,
    display_order: Field::Number,
    menu_text: Field::String,
    show_map: Field::Boolean,
    show_edna_results_metadata: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
  title
  published
  research_project
  updated_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
  id
  title
  published
  menu_text
  display_order
  slug
  research_project
  show_map
  show_edna_results_metadata
  body
  created_at
  updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
  title
  published
  menu_text
  display_order
  slug
  research_project
  show_map
  show_edna_results_metadata
  body
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how research project pages are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(research_project_page)
    research_project_page.title
  end
end
