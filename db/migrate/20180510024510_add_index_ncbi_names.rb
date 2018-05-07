class AddIndexNcbiNames < ActiveRecord::Migration[5.0]
  def up
    execute 'CREATE INDEX index_ncbi_names_on_name ON ncbi_names USING btree (lower(("name")::text));'
  end

  def down
    remove_index :ncbi_names, :index_ncbi_names_on_name
  end
end
