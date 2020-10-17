class AddFulltextIndexGbifTaxa < ActiveRecord::Migration[5.2]
  def up
    execute 'CREATE INDEX full_text_gbif_taxa_idx ON pour.gbif_taxa ' \
    "USING gin(
      (
        to_tsvector('simple', canonical_name) ||
        to_tsvector('english', coalesce(common_names, ''))
      )
    )"
  end

  def down
    remove_index 'pour.gbif_taxa', name: :full_text_gbif_taxa_idx
  end
end
