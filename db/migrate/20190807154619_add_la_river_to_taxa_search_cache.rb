class AddLaRiverToTaxaSearchCache < ActiveRecord::Migration[5.2]
  def change
    add_column :taxa_search_caches, :asvs_count_5, :integer, default: 0
    add_column :taxa_search_caches, :asvs_count_la_river, :integer, default: 0
    add_column :taxa_search_caches, :asvs_count_la_river_5, :integer, default: 0

    add_column :taxa_search_caches, :sample_ids_5, :integer,
      array: true, default: []
    add_column :taxa_search_caches, :sample_ids_la_river, :integer,
      array: true, default: []
    add_column :taxa_search_caches, :sample_ids_la_river_5, :integer,
      array: true, default: []
  end
end
