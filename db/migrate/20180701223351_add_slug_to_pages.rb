class AddSlugToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :slug, :string
    add_column :pages, :order, :integer

    add_index :pages, :slug
    add_index :pages, :order

    change_column :pages, :menu_cd, :string, :null => true

  end
end
