# frozen_string_literal: true

class GbifOccurrence < ApplicationRecord
  self.table_name = 'external.gbif_occurrences'
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
