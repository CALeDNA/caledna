class AddFieldsToSamples < ActiveRecord::Migration[5.0]
  def change
    add_column :samples, :altitude, :decimal
    change_column :samples, :latitude, :decimal
    change_column :samples, :longitude, :decimal
    add_column :samples, :gps_precision, :integer
    add_column :samples, :location, :string
  end
end
