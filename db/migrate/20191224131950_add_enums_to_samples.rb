class AddEnumsToSamples < ActiveRecord::Migration[5.2]
  def change
    rename_column :samples, :habitat, :habitat_cd
    rename_column :samples, :depth, :depth_cd
  end
end
