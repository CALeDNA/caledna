class AddTaxaCountToSamples < ActiveRecord::Migration[5.2]
  def change
    add_column :samples, :taxa_count, :integer
  end
end
