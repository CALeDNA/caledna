class AddPrefixIndexToNcbiNames < ActiveRecord::Migration[5.2]
  def change
    execute 'CREATE INDEX name_prefix ON ncbi_names USING btree (lower("name") text_pattern_ops);'
  end
end
