class RefactorCombineTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :combine_taxa, :source_superkingdom, :string
    add_column :combine_taxa, :source_kingdom, :string
    add_column :combine_taxa, :source_phylum, :string
    add_column :combine_taxa, :source_class_name, :string
    add_column :combine_taxa, :source_order, :string
    add_column :combine_taxa, :source_family, :string
    add_column :combine_taxa, :source_genus, :string
    add_column :combine_taxa, :source_species, :string
    add_column :combine_taxa, :synonym, :string
    add_column :combine_taxa, :hierarchy_names, :jsonb
    rename_column :combine_taxa, :caledna_taxonomy_string, :short_taxonomy_string
    add_column :combine_taxa, :full_taxonomy_string, :text
  end
end
