class AddColToPlaces < ActiveRecord::Migration[5.2]
  def change
    add_column :places, :huc8, :string
    add_column :places, :uc_campus, :string
    add_column :places, :gnis_id, :string
  end
end
