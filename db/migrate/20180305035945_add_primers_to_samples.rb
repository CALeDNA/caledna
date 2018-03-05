class AddPrimersToSamples < ActiveRecord::Migration[5.0]
  def change
    add_column :samples, :primer_16s, :string
    add_column :samples, :primer_18s, :string
    add_column :samples, :primer_cO1, :string
    add_column :samples, :primer_fits, :string
    add_column :samples, :primer_pits, :string
    add_column :samples, :elevatr_altitude, :decimal
    add_column :samples, :csv_data, :jsonb
  end
end
