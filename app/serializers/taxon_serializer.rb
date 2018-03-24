# frozen_string_literal: true

class TaxonSerializer
  include FastJsonapi::ObjectSerializer

  has_one :taxa_dataset, id_method_name: :datasetID

  attributes :scientificName, :canonicalName, :specificEpithet,
             :taxonRank, :taxonomicStatus, :kingdom, :phylum, :className,
             :order, :family, :genus, :hierarchy, :taxonID

  attribute :taxa_dataset do |object|
    {
      datasetID: object.taxa_dataset.datasetID,
      name: object.taxa_dataset.name
    }
  end
end
