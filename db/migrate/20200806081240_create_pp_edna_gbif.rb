class CreatePpEdnaGbif < ActiveRecord::Migration[5.2]
  def change
    create_table 'pillar_point.edna_gbif' do |t|
      t.string :superkingdom
      t.string :kingdom
      t.string :phylum
      t.string :class_name
      t.string :order
      t.string :family
      t.string :genus
      t.string :species
      t.boolean :ncbi_match
      t.boolean :edna_match
      t.integer :count
      t.string :gbif_taxa
      t.string :ncbi_taxa
      t.string :rank, index: true
    end
  end
end

