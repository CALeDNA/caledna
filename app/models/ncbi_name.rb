# frozen_string_literal: true

class NcbiName < ApplicationRecord
  scope :synonyms, (lambda do
    where("name_class != 'common name' AND name_class != 'genbank common name'")
  end)

  def ncbi_node
    NcbiNode.find_by(ncbi_id: taxon_id)
  end
end
