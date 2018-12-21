class AddIndexCombineTaxa < ActiveRecord::Migration[5.2]
  def up
    execute 'CREATE INDEX index_combine_taxa_on_phylum ON combine_taxa (lower("phylum"));'
    execute 'CREATE INDEX index_combine_taxa_on_class_name ON combine_taxa (lower("class_name"));'
    execute 'CREATE INDEX index_combine_taxa_on_order ON combine_taxa (lower("order"));'
    execute 'CREATE INDEX index_combine_taxa_on_family ON combine_taxa (lower("family"));'
    execute 'CREATE INDEX index_combine_taxa_on_genus ON combine_taxa (lower("genus"));'
    execute 'CREATE INDEX index_combine_taxa_on_species ON combine_taxa (lower("species"));'
  end

  def down
    remove_index :combine_taxa, :index_combine_taxa_on_phylum
    remove_index :combine_taxa, :index_combine_taxa_on_class_name
    remove_index :combine_taxa, :index_combine_taxa_on_order
    remove_index :combine_taxa, :index_combine_taxa_on_family
    remove_index :combine_taxa, :index_combine_taxa_on_genus
    remove_index :combine_taxa, :index_combine_taxa_on_species
  end
end
