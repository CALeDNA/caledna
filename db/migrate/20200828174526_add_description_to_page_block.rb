class AddDescriptionToPageBlock < ActiveRecord::Migration[5.2]
  def change
    add_column :page_blocks, :admin_note, :text
  end
end
