class AddMenuTextToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :menu_text, :string
  end
end
