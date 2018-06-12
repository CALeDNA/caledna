require "administrate/base_dashboard"

class PageDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    title: Field::String,
    body: Field::Text,
    draft: Field::Boolean,
    menu_cd: EnumField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :title,
    :menu_cd,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :title,
    :body,
    :draft,
    :menu_cd,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :title,
    :body,
    :draft,
    :menu_cd,
  ].freeze

  def display_resource(page)
    page.title
  end
end
