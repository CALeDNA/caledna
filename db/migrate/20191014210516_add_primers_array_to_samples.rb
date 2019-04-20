class AddPrimersArrayToSamples < ActiveRecord::Migration[5.2]
  def up
    add_column :samples, :primers, :string, array: true, default: []
    execute 'CREATE INDEX index_samples_on_primer ON samples USING gin (primers);'
  end

  def down
    remove_index :samples, name: :index_samples_on_primer
    remove_column :samples, :primers
  end
end
