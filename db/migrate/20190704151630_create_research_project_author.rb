class CreateResearchProjectAuthor < ActiveRecord::Migration[5.2]
  def change
    create_table :research_project_authors do |t|
      t.references :research_project, foreign_key: true
      t.string :authorable_type
      t.integer :authorable_id, index: true
      t.timestamps
    end
  end
end

