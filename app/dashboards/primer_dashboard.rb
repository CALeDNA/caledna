require "administrate/base_dashboard"

class PrimerDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    sequence_1: Field::Text,
    sequence_2: Field::Text,
    reference: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
  ].freeze

   SHOW_PAGE_ATTRIBUTES = [
    :name,
    :sequence_1,
    :sequence_2,
    :reference,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
    :sequence_1,
    :sequence_2,
    :reference,
  ].freeze

  def display_resource(primer)
    "Primer #{primer.name}"
  end
end
