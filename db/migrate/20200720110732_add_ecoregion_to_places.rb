class AddEcoregionToPlaces < ActiveRecord::Migration[5.2]
  def change
    add_column :places, :us_l4code, :string
    add_column :places, :us_l4name, :string
    add_column :places, :us_l3code, :string
    add_column :places, :us_l3name, :string
    add_column :places, :na_l3code, :string
    add_column :places, :na_l3name, :string
    add_column :places, :na_l2code, :string
    add_column :places, :na_l2name, :string
    add_column :places, :na_l1code, :string
    add_column :places, :na_l1name, :string
  end
end


