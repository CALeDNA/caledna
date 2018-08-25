class AddCoordsIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :samples, [:latitude, :longitude]
  end
end
