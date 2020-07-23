class AddWebsiteToPageBlocks < ActiveRecord::Migration[5.2]
  def change
    add_reference :page_blocks, :website, foreign_key:  { to_table: :websites }
  end
end
