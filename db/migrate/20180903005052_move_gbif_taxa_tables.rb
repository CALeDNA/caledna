class MoveGbifTaxaTables < ActiveRecord::Migration[5.2]
  def up
    rename_table :taxa, :gbif_taxa
    rename_table :vernaculars, :gbif_vernaculars
    rename_table :taxa_datasets, :gbif_datasets
    execute 'ALTER TABLE gbif_taxa SET SCHEMA external;'
    execute 'ALTER TABLE gbif_vernaculars SET SCHEMA external;'
    execute 'ALTER TABLE gbif_datasets SET SCHEMA external;'
  end

  def down
    execute 'ALTER TABLE gbif_taxa SET SCHEMA public;'
    execute 'ALTER TABLE gbif_vernaculars SET SCHEMA public;'
    execute 'ALTER TABLE gbif_datasets SET SCHEMA public;'
    rename_table :gbif_taxa, :taxa
    rename_table :gbif_vernaculars, :vernaculars
    rename_table :gbif_datasets, :taxa_datasets
  end
end
