# frozen_string_literal: true

class NcbiCitationNode < ApplicationRecord
  belongs_to :ncbi_citation
  belongs_to :ncbi_node
end
