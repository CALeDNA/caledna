# frozen_string_literal: true

class NcbiCitation < ApplicationRecord
  has_many :ncbi_citation_nodes
  has_many :ncbi_nodes, through: :ncbi_citation_nodes
end
