class CreatePourInat < ActiveRecord::Migration[5.2]
  def change
    create_table 'pour.inat_taxa' do |t|
      t.string :scientific_name, index: true
      t.string :common_name, index: true
      t.string :iconic_taxon_name
      t.string :kingdom
      t.string :phylum
      t.string :class_name
      t.string :order
      t.string :family
      t.string :genus
      t.string :species
      t.string :rank
      t.bigint :inat_id, index: true
      t.bigint :gbif_id, index: true
      t.bigint :ncbi_id, index: true
    end
  end
end
