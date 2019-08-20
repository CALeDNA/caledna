require "administrate/base_dashboard"

class SiteNewsDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    website: Field::BelongsTo,
    id: Field::Number,
    title: Field::String,
    body: TextEditorField,
    published: Field::Boolean,
    websites_id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    published_date: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :title,
    :website,
    :published_date
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :title,
    :body,
    :published,
    :published_date,
    :website,
    :created_at,
  ].freeze


  FORM_ATTRIBUTES = [
    :title,
    :body,
    :published,
    :published_date,
    :website,
  ].freeze

  # def display_resource(site_new)
  #   "SiteNew ##{site_new.id}"
  # end
end
