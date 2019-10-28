class EditSampleFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :samples, :alt_id, :string
    remove_column :samples, :elevatr_altitude, :decimal
    remove_column :samples, :ecosystem_category_cd, :string
    add_column :samples, :csv_data, :jsonb, default: {}
  end
end
