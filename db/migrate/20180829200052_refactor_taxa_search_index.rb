class RefactorTaxaSearchIndex < ActiveRecord::Migration[5.2]
  def up
    remove_index :ncbi_nodes, name: :idx_taxa_search

    execute 'CREATE INDEX idx_taxa_search ON ncbi_nodes ' \
    "USING gin(
      (
        to_tsvector('simple', canonical_name) ||
        to_tsvector('english', coalesce(alt_names, ''))
      )
    )"
  end

  def down
    remove_index :ncbi_nodes, name: :idx_taxa_search
  end
end
