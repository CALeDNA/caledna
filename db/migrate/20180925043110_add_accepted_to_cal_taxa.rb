class AddAcceptedToCalTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :cal_taxa, :accepted, :boolean, default: false
  end
end
