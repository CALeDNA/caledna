class RedoFullTextIndexTaxa < ActiveRecord::Migration[5.2]
  def change
    remove_index :ncbi_nodes, :full_text_search_idx
    sql = <<~SQL
    CREATE INDEX full_text_search_idx ON ncbi_nodes USING gin(
      (to_tsvector('simple', canonical_name) || to_tsvector('english', common_names))
    );
    SQL
    execute sql
  end
end
