class AddCommonNamesToPourGibf < ActiveRecord::Migration[5.2]
  def change
    add_column 'pour.gbif_taxa', :common_names, :text
    sql = <<~SQL
      CREATE INDEX full_text_search_gc_idx ON pour.gbif_taxa USING gin(
        to_tsvector('english', common_names)
      );
    SQL
    execute sql
  end
end
