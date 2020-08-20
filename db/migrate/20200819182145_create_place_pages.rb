class CreatePlacePages < ActiveRecord::Migration[5.2]
  def change
    create_table :place_pages do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.boolean :published, default: false, null: false
      t.string :slug, index: true
      t.integer :display_order
      t.references :place
      t.string :menu_text
      t.boolean :show_map

      t.timestamps
    end
  end
end
