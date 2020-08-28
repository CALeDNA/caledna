require "administrate/base_dashboard"

class PageBlockDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    page: Field::BelongsTo,
    id: Field::Number,
    content: TextEditorField,
    slug: Field::String,
    admin_note: Field::Text,
    image: ActiveStorageAttachmentField,
    image_position_cd: EnumField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    website: Field::BelongsTo.with_options(
      searchable: true,
      searchable_field: 'name'
    ),
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
  slug
  page
  admin_note
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  id
  slug
  content
  admin_note
  page
  website
  image
  image_position_cd
  created_at
  updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  slug
  content
  admin_note
  page
  website
  image
  image_position_cd
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

  def display_resource(page_block)
    "PageBlock #{page_block.slug}"
  end
end
