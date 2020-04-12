class AddIndexNcbiImport < ActiveRecord::Migration[5.2]
  def up
    add_index :ncbi_names, :name_class

    add_index :ncbi_nodes, :hierarchy_names, using: :gin
    add_index :ncbi_nodes, :hierarchy, using: :gin
    add_index :ncbi_nodes, :ids, using: :gin
    add_index :ncbi_nodes, :asvs_count
    add_index :ncbi_nodes, :asvs_count_la_river
    add_index :ncbi_nodes, :rank
    add_index :ncbi_nodes, :cal_division_id
    add_index :ncbi_nodes, :bold_id

    execute "CREATE INDEX replace_quotes_idx ON ncbi_nodes USING btree (lower((REPLACE(canonical_name, '''', ''))::text));"
    execute 'CREATE INDEX name_autocomplete_idx ON ncbi_nodes USING btree (lower ("canonical_name") text_pattern_ops);'
    execute "CREATE INDEX full_text_search_idx ON ncbi_nodes USING gin(( to_tsvector('simple', canonical_name) || to_tsvector('english', coalesce(alt_names, ''))));"
  end

  def down
    remove_index :ncbi_names, :name_class

    remove_index :ncbi_nodes, :hierarchy_names
    remove_index :ncbi_nodes, :hierarchy
    remove_index :ncbi_nodes, :ids
    remove_index :ncbi_nodes, :asvs_count
    remove_index :ncbi_nodes, :asvs_count_la_river
    remove_index :ncbi_nodes, :rank
    remove_index :ncbi_nodes, :cal_division_id
    remove_index :ncbi_nodes, :bold_id

    execute "DROP INDEX replace_quotes_idx ;"
    execute 'DROP INDEX name_autocomplete_idx ;'
    execute "DROP INDEX full_text_search_idx ;"
  end
end

