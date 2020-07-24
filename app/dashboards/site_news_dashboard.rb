require "administrate/base_dashboard"

class SiteNewsDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    website: Field::BelongsTo,
    id: Field::Number,
    title: Field::String,
    body: TextEditorField,
    published: Field::Boolean,
    websites_id: Field::Number,
    image: ActiveStorageAttachmentField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    published_date: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :title,
    :published_date
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :title,
    :published,
    :published_date,
    :body,
    :image,
    :website,
    :created_at,
  ].freeze


  FORM_ATTRIBUTES = [
    :title,
    :published,
    :published_date,
    :body,
    :image,
    :website,
  ].freeze

  def display_resource(site_new)
    site_new.title
  end
end
