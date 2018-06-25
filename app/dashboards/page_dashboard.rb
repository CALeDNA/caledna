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
    order: Field::Number,
    slug: Field::String
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :title,
    :menu_cd,
    :order,
    :published
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :title,
    :body,
    :published,
    :menu_cd,
    :order,
    :slug,
    :created_at,
    :updated_at
  ].freeze

  FORM_ATTRIBUTES = [
    :title,
    :body,
    :published,
    :menu_cd,
    :order,
    :slug
  ].freeze

  def display_resource(page)
    page.title
  end
end
