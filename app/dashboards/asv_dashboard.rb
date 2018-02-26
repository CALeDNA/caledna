require "administrate/base_dashboard"

class AsvDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    extraction: Field::BelongsTo,
    taxon: Field::BelongsTo,
    id: Field::Number,
    extraction_id: Field::Number,
    taxonID: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :extraction,
    :taxon
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :extraction,
    :taxon,
    :created_at,
    :updated_at,
  ].freeze

   FORM_ATTRIBUTES = [
    :extraction,
    :taxonID,
  ].freeze

  def display_resource(asv)
    "Asv for #{asv.extraction.sample.barcode}"
  end
end
