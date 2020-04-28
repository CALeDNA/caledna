require "administrate/base_dashboard"

class PrimerDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    forward_primer: Field::Text,
    reverse_primer: Field::Text,
    reference: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
    :updated_at,
  ].freeze

   SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :forward_primer,
    :reverse_primer,
    :reference,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
    :forward_primer,
    :reverse_primer,
    :reference,
  ].freeze

  def display_resource(primer)
    "Primer #{primer.name}"
  end
end
