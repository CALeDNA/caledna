class Add < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :wiki_excerpt, :text
    add_column :external_resources, :wiki_title, :string
  end
end
