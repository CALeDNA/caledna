class AddPrimersToAsvs < ActiveRecord::Migration[5.0]
  def change
    add_column :asvs, :primers, :text, array:true, default: []
    remove_column :samples, :primer_16s, :string
    remove_column :samples, :primer_18s, :string
    remove_column :samples, :primer_cO1, :string
    remove_column :samples, :primer_fits, :string
    remove_column :samples, :primer_pits, :string
    remove_column :samples, :csv_data, :jsonb
  end
end
