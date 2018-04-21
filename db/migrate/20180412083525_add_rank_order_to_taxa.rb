class AddRankOrderToTaxa < ActiveRecord::Migration[5.0]
  def change
    add_column :taxa, :rank_order, :integer, index: true
    add_column :cal_taxa, :rank_order, :integer, index: true
  end
end
