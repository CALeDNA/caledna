# frozen_string_literal: true

class Place < ApplicationRecord
  belongs_to :place_source, optional: true
  has_many :place_pages

  as_enum :place_type, %i[state watershed county place neighborhood UCNRS
                          zip_code river ecoregions_l3 ecoregions_l4 ecotopes
                          pour_location],
          map: :string
  as_enum :place_source_type, %i[census USGS UCNRS LA_neighborhood
                                 LA_zip_code LA_river EPA LASAN],
          map: :string

  validates :name, :latitude, :longitude, :place_type,
            :place_source_type, presence: true
end
