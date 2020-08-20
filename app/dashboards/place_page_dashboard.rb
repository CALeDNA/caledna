require "administrate/base_dashboard"

class PlacePageDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    place: Field::BelongsTo,
    id: Field::Number,
    title: Field::String,
    body: TextEditorField,
    published: Field::Boolean,
    slug: Field::String,
    display_order: Field::Number,
    menu_text: Field::String,
    show_map: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
  title
  place
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  id
  title
  place
  published
  slug
  display_order
  menu_text
  show_map
  body
  created_at
  updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  title
  place
  published
  slug
  display_order
  menu_text
  show_map
  body
  ].freeze

  COLLECTION_FILTERS = {}.freeze


  def display_resource(place_page)
    place_page.title
  end
end
