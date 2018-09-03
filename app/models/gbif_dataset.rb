# frozen_string_literal: true

class GbifDataset < ApplicationRecord
  self.table_name = 'external.gbif_dataset'
  self.primary_key = :datasetID

  has_many :taxa, foreign_key: 'datasetID'

  def self.gbif_backbone
    find('d7dddbf4-2cf0-4f39-9b2a-bb099caae36c')
  end

  def url
    "https://www.gbif.org/dataset/#{datasetID}"
  end
end
