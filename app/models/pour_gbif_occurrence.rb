# frozen_string_literal: true

class PourGbifOccurrence < ApplicationRecord
  include AutoUpdateGeom

  self.table_name = 'pour.gbif_occurrences'
  self.primary_key = :gbif_id
end
