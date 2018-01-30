class RemoveUnnnededSampleFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :samples, :kit_number, :string
    remove_column :samples, :site_number, :string
    remove_column :samples, :location_letter, :string
  end
end
