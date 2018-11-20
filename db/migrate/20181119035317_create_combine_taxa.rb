class CreateCombineTaxa < ActiveRecord::Migration[5.2]
  def change
    create_table :combine_taxa do |t|
      t.bigint :taxon_id
      t.string :source
      t.string :superkingdom
      t.string :kingdom
      t.string :phylum
      t.string :class_name
      t.string :order
      t.string :family
      t.string :genus
      t.string :species
      t.string :taxon_rank
      t.string :canonical_name
      t.text :caledna_taxonomy_string
      t.text :notes
    end
  end
end
