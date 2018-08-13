# frozen_string_literal: true

class NcbiName < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_name, :against => :name

  belongs_to :ncbi_node, foreign_key: 'taxon_id'

  scope :vernaculars, (lambda do
    where("name_class = 'common name' OR name_class = 'genbank common name'")
  end)

  scope :synonyms, (lambda do
    where("name_class != 'common name' AND name_class != 'genbank common name'")
  end)
end
