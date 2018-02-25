# frozen_string_literal: true

class TaxaDataset < ApplicationRecord
  self.primary_key = :datasetID

  has_many :taxa, foreign_key: 'datasetID'

  def self.gbif_backbone
    find('d7dddbf4-2cf0-4f39-9b2a-bb099caae36c')
  end

  def url
    "https://www.gbif.org/dataset/#{datasetID}"
  end
end
