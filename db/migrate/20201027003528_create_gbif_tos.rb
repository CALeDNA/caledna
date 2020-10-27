class CreateGbifTos < ActiveRecord::Migration[5.2]
  def change
    create_table 'external.gbif_taxa_tos', id: false do |t|
      t.bigint :taxon_id, primary_key: true
      t.string :kingdom
      t.bigint :kingdom_id
      t.string :phylum
      t.bigint :phylum_id
      t.string :class_name
      t.bigint :class_id
      t.string :order
      t.bigint :order_id
      t.string :family
      t.bigint :family_id
      t.string :genus
      t.bigint :genus_id
      t.string :species
      t.bigint :species_id
      t.string :taxon_rank, index: true
      t.string :scientific_name
      t.string :taxonomic_status, index: true
      t.string :accepted_scientific_name
      t.string :accepted_taxon_id
      t.integer :occurrence_count
      t.string :canonical_name, index: true
      t.string :image
      t.bigint :ncbi_id, index: true
      t.integer :tos
      t.timestamps
    end
  end
end
