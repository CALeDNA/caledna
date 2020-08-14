require "administrate/base_dashboard"

class PageDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    title: Field::String,
    body: TextEditorField,
    published: Field::Boolean,
    menu_cd: EnumField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    display_order: Field::Number,
    slug: Field::String,
    website: Field::BelongsTo.with_options(
      searchable: true,
      searchable_field: 'name',
      optional: true
    ),
    menu_text: Field::String,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :title,
    :published,
    :updated_at,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :title,
    :published,
    :slug,
    :website,
    :body,
    :created_at,
    :updated_at
  ].freeze

  FORM_ATTRIBUTES = [
    :title,
    :published,
    :slug,
    :website,
    :body,
  ].freeze

  def display_resource(page)
    page.title
  end
end
