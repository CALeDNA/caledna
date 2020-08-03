class AddStatToWebsite < ActiveRecord::Migration[5.2]
  def change
    add_column :websites, :taxa_count, :integer
    add_column :websites, :species_count, :integer
    add_column :websites, :families_count, :integer
  end
end
