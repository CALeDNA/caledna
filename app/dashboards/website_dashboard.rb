require "administrate/base_dashboard"

class WebsiteDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    pages: Field::HasMany,
    id: Field::Number,
    name: Field::String,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
  ].freeze

  def display_resource(website)
    website.name
  end
end
