class AddIndexForAreaDiversity2 < ActiveRecord::Migration[5.2]
  def change
    add_index :combine_taxa, :source
    add_index :combine_taxa, :kingdom
  end
end
