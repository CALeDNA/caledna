class CreatePageBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :page_blocks do |t|
      t.text :content
      t.references :page
      t.string :slug, index: { unique: true }
      t.string :image_position_cd
      t.timestamps
    end
  end
end
