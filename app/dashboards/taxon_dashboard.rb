# frozen_string_literal: true

require "administrate/base_dashboard"

class TaxonDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    vernaculars: Field::HasMany,
    asvs: Field::HasMany,
    highlights: Field::HasMany,
    taxonID: Field::Number,
    datasetID: Field::String,
    parentNameUsageID: Field::Number,
    acceptedNameUsageID: Field::Number,
    originalNameUsageID: Field::Number,
    scientificName: Field::Text,
    scientificNameAuthorship: Field::Text,
    canonicalName: Field::String,
    genericName: Field::String,
    specificEpithet: Field::String,
    infraspecificEpithet: Field::String,
    taxonRank: Field::String,
    nameAccordingTo: Field::String,
    namePublishedIn: Field::Text,
    taxonomicStatus: Field::String,
    nomenclaturalStatus: Field::String,
    taxonRemarks: Field::String,
    kingdom: Field::String,
    phylum: Field::String,
    className: Field::String,
    order: Field::String,
    family: Field::String,
    genus: Field::String,
    hierarchy: Field::String.with_options(searchable: false),
    asvs_count: Field::Number,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :vernaculars,
    :asvs,
    :highlights,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :vernaculars,
    :asvs,
    :highlights,
    :taxonID,
    :datasetID,
    :parentNameUsageID,
    :acceptedNameUsageID,
    :originalNameUsageID,
    :scientificName,
    :scientificNameAuthorship,
    :canonicalName,
    :genericName,
    :specificEpithet,
    :infraspecificEpithet,
    :taxonRank,
    :nameAccordingTo,
    :namePublishedIn,
    :taxonomicStatus,
    :nomenclaturalStatus,
    :taxonRemarks,
    :kingdom,
    :phylum,
    :className,
    :order,
    :family,
    :genus,
    :hierarchy,
    :asvs_count,
  ].freeze

  FORM_ATTRIBUTES = [
    :vernaculars,
    :asvs,
    :highlights,
    :taxonID,
    :datasetID,
    :parentNameUsageID,
    :acceptedNameUsageID,
    :originalNameUsageID,
    :scientificName,
    :scientificNameAuthorship,
    :canonicalName,
    :genericName,
    :specificEpithet,
    :infraspecificEpithet,
    :taxonRank,
    :nameAccordingTo,
    :namePublishedIn,
    :taxonomicStatus,
    :nomenclaturalStatus,
    :taxonRemarks,
    :kingdom,
    :phylum,
    :className,
    :order,
    :family,
    :genus,
    :hierarchy,
    :asvs_count,
  ].freeze

  def display_resource(taxon)
    taxon.canonicalName
  end
end
