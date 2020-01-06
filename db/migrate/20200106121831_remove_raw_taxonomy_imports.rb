class RemoveRawTaxonomyImports < ActiveRecord::Migration[5.2]
  def change
    drop_table :raw_taxonomy_imports do |t|
    end
  end
end
