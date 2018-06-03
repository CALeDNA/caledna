class AddReplaceIndexNcbiNodes < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE INDEX replace_quotes_idx ON ncbi_nodes USING btree (lower((REPLACE(canonical_name, '''', ''))::text));"
  end

  def down
    remove_index :replace_quotes_idx
  end
end
