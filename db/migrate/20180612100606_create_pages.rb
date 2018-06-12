class CreatePages < ActiveRecord::Migration[5.0]
  def change
    create_table :pages do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.boolean :draft, null: false, default: false
      t.string :menu_cd, null: false

      t.timestamps
    end
  end
end
