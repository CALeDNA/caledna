class AddIndexNcbiNodes < ActiveRecord::Migration[5.0]
  def up
    execute 'CREATE INDEX index_ncbi_nodes_on_canonical_name ON ncbi_nodes USING btree (lower(("canonical_name")::text));'
  end

  def down
    remove_index :ncbi_nodes, :index_ncbi_nodes_on_canonical_name
  end
end
