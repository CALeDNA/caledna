class CreateGbifOccTaxa < ActiveRecord::Migration[5.2]
  def up
    script = Rails.root.join('db').join('data').join('gbif_occ_taxa_schema.sql')
    execute File.read(script)
  end

  def down
    drop_table 'external.gbif_occ_taxa'
  end
end
