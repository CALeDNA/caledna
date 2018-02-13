require "administrate/base_dashboard"

class AsvDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    # taxonomic_unit: Field::BelongsTo,
    extraction: Field::BelongsTo,
    # hierarchy: Field::HasOne,
    id: Field::Number,
    tsn: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    # :taxonomic_unit,
    :extraction,
    # :hierarchy,
    :tsn
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    # :taxonomic_unit,
    :extraction,
    # :hierarchy,
    # :tsn,
    :created_at,
    :updated_at,
  ].freeze

   FORM_ATTRIBUTES = [
    # :taxonomic_unit,
    :extraction,
    # :hierarchy,
    # :tsn,
  ].freeze

  def display_resource(asv)
    "Asv ##{asv.id}"
  end
end
