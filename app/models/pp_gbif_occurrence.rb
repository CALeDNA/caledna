# frozen_string_literal: true

class PpGbifOccurrence < ApplicationRecord
  self.table_name = 'pillar_point.gbif_occurrences'
  self.primary_key = 'gbifid'

  has_many :research_project_sources, as: :sourceable

  def latitude
    decimallatitude
  end

  def longitude
    decimallongitude
  end

  def id
    gbifid
  end
end
