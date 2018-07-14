class AddSlugToSurvey < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :slug, :string
    add_index :surveys, :slug

    add_column :surveys, :description, :text
  end
end
