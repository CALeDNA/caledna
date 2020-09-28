class AddFullTextToGbifCommonNames < ActiveRecord::Migration[5.2]
  def change
    sql = <<~SQL
    CREATE INDEX full_text_search_idx ON pour.gbif_common_names USING gin(
      to_tsvector('english', vernacular_name)
    );
    SQL
    execute sql
  end
end
