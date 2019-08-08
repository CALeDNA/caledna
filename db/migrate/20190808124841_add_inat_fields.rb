class AddInatFields < ActiveRecord::Migration[5.2]
  def change
    add_column :inat_taxa, :species, :string
    add_column :inat_observations, :species, :string
    add_column :inat_observations, :commonName, :string
    add_column :inat_observations, :positionalAccuracy, :integer
    add_column :inat_observations, :url, :string
    add_column :inat_observations, :imageUrl, :string
  end
end
