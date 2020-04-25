class CreateResultsRawImport < ActiveRecord::Migration[5.2]
  def change
    create_table :result_raw_imports do |t|
      t.string :original_taxonomy_string
      t.string :clean_taxonomy_string
      t.string :canonical_name
      t.string :primer
      t.references :research_project
      t.jsonb :payload
      t.timestamps
    end
  end
end
