class AddIucnStatusToTaxa < ActiveRecord::Migration[5.0]
  def change
    add_column :taxa, :iucn_status, :string
  end
end
