require "administrate/base_dashboard"

class PlaceSourceDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    places: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    url: Field::String,
    file_name: Field::String,
    place_source_type_cd: EnumField,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
  id
  name
  url
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
  id
  name
  url
  file_name
  place_source_type_cd
  places
  ].freeze

  FORM_ATTRIBUTES = %i[
  name
  url
  file_name
  place_source_type_cd
  places
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(place_source)
    place_source.name
  end
end
