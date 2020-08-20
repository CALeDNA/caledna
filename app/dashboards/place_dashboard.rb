require "administrate/base_dashboard"

class PlaceDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    place_source: Field::BelongsTo,
    pages: Field::HasMany,
    id: Field::Number,
    name: Field::String,
    state_fips: Field::Number,
    county_fips: Field::Number,
    place_fips: Field::Number,
    lsad: Field::Number,
    place_type_cd: EnumField.with_options(searchable: true),
    latitude: Field::String.with_options(searchable: false),
    longitude: Field::String.with_options(searchable: false),
    geom: Field::String.with_options(searchable: false),
    place_source_type_cd: EnumField,
    huc8: Field::String,
    uc_campus: Field::String,
    gnis_id: Field::String,
    us_l4code: Field::String,
    us_l4name: Field::String,
    us_l3code: Field::String,
    us_l3name: Field::String,
    na_l3code: Field::String,
    na_l3name: Field::String,
    na_l2code: Field::String,
    na_l2name: Field::String,
    na_l1code: Field::String,
    na_l1name: Field::String,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
  name
  place_type_cd
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
  id
  name
  latitude
  longitude
  place_type_cd
  place_source_type_cd
  geom
  state_fips
  county_fips
  place_fips
  lsad
  huc8
  uc_campus
  gnis_id
  us_l4code
  us_l4name
  us_l3code
  us_l3name
  na_l3code
  na_l3name
  na_l2code
  na_l2name
  na_l1code
  na_l1name
  ].freeze

  FORM_ATTRIBUTES = %i[
  name
  latitude
  longitude
  place_type_cd
  place_source_type_cd
  geom
  state_fips
  county_fips
  place_fips
  lsad
  huc8
  uc_campus
  gnis_id
  us_l4code
  us_l4name
  us_l3code
  us_l3name
  na_l3code
  na_l3name
  na_l2code
  na_l2name
  na_l1code
  na_l1name
  ].freeze

  def display_resource(place)
    "#{place.name} (#{place.place_type_cd})"
  end
end
