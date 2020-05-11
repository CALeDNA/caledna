class CreateUnmatchedResults < ActiveRecord::Migration[5.2]
  def change
    create_table :unmatched_results do |t|
      t.string :taxonomy_string
      t.string :clean_taxonomy_string
      t.references :primer
      t.references :research_project
      t.boolean :normalized
    end
  end
end
