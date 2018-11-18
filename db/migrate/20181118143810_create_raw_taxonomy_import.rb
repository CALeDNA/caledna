class CreateRawTaxonomyImport < ActiveRecord::Migration[5.2]
  def change
    create_table :raw_taxonomy_imports do |t|
      t.string :name
      t.string :taxonomy_string
      t.string :primer
      t.text :notes
      t.references :research_project
    end
  end
end
