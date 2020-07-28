class CreatePourGbifTaxa < ActiveRecord::Migration[5.2]
  def change
    create_schema :pour
    create_table 'pour.gbif_taxa', id: false do |t|
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
      t.string :infraspecific_epithet
      t.string :rank
      t.string :scientific_name
      t.string :taxonomic_status
      t.string :accepted_scientific_name
      t.string :accepted_taxon_id

      t.timestamps
    end
  end
end

