# frozen_string_literal: true

class Place < ApplicationRecord
  belongs_to :place_source, optional: true

  as_enum :place_type, %i[state watershed county place neighborhood UCNRS
                          zipcode], map: :string
  as_enum :place_source_type, %i[census USGS zipcode UCNRS LA_neighborhood],
          map: :string
end
