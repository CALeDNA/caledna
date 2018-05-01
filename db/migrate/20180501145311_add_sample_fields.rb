class AddSampleFields < ActiveRecord::Migration[5.0]
  def change
    add_column :samples, :habitat, :string
    add_column :samples, :depth, :string
    add_column :samples, :environmental_features, :string
    add_column :samples, :environmental_settings, :string
  end
end
