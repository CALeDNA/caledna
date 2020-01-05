class CleanUpCalTaxa < ActiveRecord::Migration[5.2]
  def change
    remove_column :cal_taxa, "datasetID", :string
    remove_column :cal_taxa, "parentNameUsageID", :string
    remove_column :cal_taxa, "scientificName", :text
    remove_column :cal_taxa, "canonicalName", :string
    remove_column :cal_taxa, "taxonomicStatus", :string
    # remove_column :cal_taxa, "datasetID", :string
    remove_column :cal_taxa, :kingdom, :string
    remove_column :cal_taxa, :phylum, :string
    remove_column :cal_taxa, "className", :string
    remove_column :cal_taxa, "order", :string
    remove_column :cal_taxa, :family, :string
    remove_column :cal_taxa, :genus, :string
    remove_column :cal_taxa, "specificEpithet", :string
    remove_column :cal_taxa, "genericName", :string
    remove_column :cal_taxa, :original_hierarchy, :jsonb
    remove_column :cal_taxa, :notes, :text
    remove_column :cal_taxa, :rank_order, :integer

    add_column :cal_taxa, :original_taxonomy_string, :string
    add_column :cal_taxa, :clean_taxonomy_string, :string

    rename_column :cal_taxa, "taxonID", :taxon_id
    rename_column :cal_taxa, "taxonRank", :taxon_rank
    rename_column :cal_taxa, :accepted, :ignore

    remove_column :cal_taxa, :complete_taxonomy, :string
    remove_column :cal_taxa, :original_taxonomy_superkingdom, :string
    remove_column :cal_taxa, :original_taxonomy_phylum, :string
    remove_column :cal_taxa, :exact_gbif_match, :boolean

    add_index :cal_taxa, :clean_taxonomy_string
    add_index :cal_taxa, :ignore
  end
end
