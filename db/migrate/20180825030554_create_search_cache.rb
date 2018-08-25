class CreateSearchCache < ActiveRecord::Migration[5.2]
  def change
    create_table :taxa_search_caches do |t|
      t.integer :taxon_id
      t.integer :sample_ids, array: true
      t.integer :asvs_count
      t.string :rank
      t.string :canonical_name

      t.timestamps

    end
  end
end
