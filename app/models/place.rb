# frozen_string_literal: true

class Place < ApplicationRecord
  belongs_to :place_source, optional: true

  as_enum :place_type, %i[state watershed county place neighborhood UCNRS
                          zip_code river], map: :string
  as_enum :place_source_type, %i[census USGS UCNRS LA_neighborhood
                                 LA_zip_code LA_river],
          map: :string
end
