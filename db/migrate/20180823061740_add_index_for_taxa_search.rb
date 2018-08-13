class AddIndexForTaxaSearch < ActiveRecord::Migration[5.2]
  def up
    execute 'CREATE INDEX idx_taxa_search ON ncbi_nodes ' \
    "USING gin((to_tsvector('simple', canonical_name) || to_tsvector('english', alt_names)))"
  end

  def down
    remove_index :ncbi_nodes, :idx_taxa_search
  end
end
