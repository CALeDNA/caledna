class UpdateRawTaxonomyImports < ActiveRecord::Migration[5.2]
  def change
    add_column :raw_taxonomy_imports, :created_at, :datetime
    add_column :raw_taxonomy_imports, :updated_at, :datetime
    remove_column :raw_taxonomy_imports, :notes, :text
  end
end
