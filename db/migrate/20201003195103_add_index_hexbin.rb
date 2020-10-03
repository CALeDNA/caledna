class AddIndexHexbin < ActiveRecord::Migration[5.2]
  def change
    add_index 'pour.hexbin', :geom, using: :gist
    rename_column 'pour.hexbin', :distance, :size
  end
end
