class AddIndexGbifOccurences < ActiveRecord::Migration[5.2]
  def up
    execute 'CREATE INDEX index_gbif_occurrences_on_genus ON external.gbif_occurrences USING btree (lower(("genus")::text));'
  end

  def down
    remove_index 'external.gbif_occurrences', :index_gbif_occurrences_on_genus
  end
end
