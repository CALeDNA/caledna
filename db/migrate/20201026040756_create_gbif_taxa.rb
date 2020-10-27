class CreateGbifTaxa < ActiveRecord::Migration[5.2]
  def change
    create_table 'external.gbif_taxa' do |t|
      t.bigint :gbif_id, index: true
      t.string :kingdom
      t.string :phylum
      t.string :class_name
      t.string :order
      t.string :family
      t.string :genus
      t.string :species
      t.string :infraspecies
      t.string :canonical_name, index: true
      t.string :taxon_rank
      t.string :taxonomic_status, index: true
      t.string :accepted_taxon_id
      t.bigint :ncbi_id, index: true
      t.string :ncbi_name
      t.string :source
    end
  end
end

