require "administrate/base_dashboard"

class UserSubmissionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    user: Field::BelongsTo,
    user_display_name: Field::String,
    title: Field::String,
    user_bio: TextEditorField,
    content: TextEditorField,
    media_url: Field::String,
    embed_code: Field::String,
    twitter: Field::String,
    facebook: Field::String,
    instagram: Field::String,
    website: Field::String,
    approved: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    image: ActiveStorageAttachmentField,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
  id
  user
  title
  approved
  created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
  id
  approved
  user_display_name
  title
  user_bio
  content
  image
  media_url
  embed_code
  twitter
  facebook
  instagram
  website
  created_at
  updated_at
  ].freeze


  FORM_ATTRIBUTES = %i[
  approved
  user
  user_display_name
  title
  user_bio
  content
  image
  media_url
  embed_code
  twitter
  facebook
  instagram
  website
  ].freeze


  COLLECTION_FILTERS = {}.freeze


  def display_resource(user_submission)
    user_submission.title
  end
end
