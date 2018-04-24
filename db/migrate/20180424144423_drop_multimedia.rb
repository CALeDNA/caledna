class DropMultimedia < ActiveRecord::Migration[5.0]
  def up
    drop_table :multimedia
  end

  def down; end
end
