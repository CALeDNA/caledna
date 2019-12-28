class AddAutosuggestIndexNcbiNode < ActiveRecord::Migration[5.2]
  def up
    execute 'CREATE INDEX canonical_name_prefix ON ncbi_nodes USING btree ( lower ("canonical_name") text_pattern_ops);'
  end
  def down
    remove_index :ncbi_nodes, :canonical_name_prefix
  end
end
