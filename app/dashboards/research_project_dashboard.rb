# frozen_string_literal: true

require "administrate/base_dashboard"

class ResearchProjectDashboard < Administrate::BaseDashboard
  ARRAY_FIELDS = %i[primers]

  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    published: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    researcher_authors: ProjectAuthorField,
    user_authors: ProjectAuthorField,
    reference_barcode_database: Field::Text,
    dryad_link: Field::String,
    decontamination_method: Field::Text,
    slug: Field::String,
    metadata: Field::JSON.with_options(searchable: false),
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :name,
    :published,
    :created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :name,
    :published,
    :slug,
    :reference_barcode_database,
    :dryad_link,
    :decontamination_method,
    :researcher_authors,
    :user_authors,
    :created_at,
    :updated_at,
    :metadata
  ].freeze

  FORM_ATTRIBUTES = [
    :name,
    :published,
    :slug,
    :reference_barcode_database,
    :dryad_link,
    :decontamination_method,
    :researcher_authors,
    :user_authors
  ].freeze


  def display_resource(research_project)
    "Research Project: #{research_project.name}"
  end

  def permitted_attributes
    super + ARRAY_FIELDS.map { |f| { f => []} }
  end
end
