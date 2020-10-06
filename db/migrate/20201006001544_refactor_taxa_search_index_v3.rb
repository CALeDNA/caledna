class RefactorTaxaSearchIndexV3 < ActiveRecord::Migration[5.2]
  def up
    remove_index :ncbi_nodes, name: :full_text_search_idx

    execute 'CREATE INDEX full_text_search_idx ON ncbi_nodes ' \
    "USING gin(
      (
        to_tsvector('simple', canonical_name) ||
        to_tsvector('english', coalesce(common_names, ''))
      )
    )"
  end

  def down
    remove_index :ncbi_nodes, name: :full_text_search_idx
  end
end
