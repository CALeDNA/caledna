class ChangeGlobiTableNames < ActiveRecord::Migration[5.2]
  def up
    drop_table 'external.globi_interactions'
    execute 'ALTER TABLE external.globi_raw RENAME TO globi_interactions'
    remove_column 'external.globi_requests', :url
    remove_column 'external.globi_requests', :location
    add_column 'external.globi_requests', :metadata, :jsonb, default: {}
    change_column 'external.globi_requests', :taxon_id, "varchar[] USING (string_to_array('NCBI:'||taxon_id::text, ''))"
  end

  def down
    execute 'ALTER TABLE external.globi_interactions RENAME TO globi_raw'
    create_table 'external.globi_interactions' do |t|
      t.string :source_taxon_external_id
      t.string :source_taxon_name
      t.string :source_taxon_path
      t.string :target_taxon_external_id
      t.string :target_taxon_name
      t.string :target_taxon_path
      t.string :interaction_type
      t.decimal :latitude
      t.decimal :longitude
      t.string :url

      t.timestamps
    end

    add_column 'external.globi_requests', :url, :string
    add_column 'external.globi_requests', :location, :string
    add_remove 'external.globi_requests', :metadata
    change_column 'external.globi_requests', :taxon_id, :string
  end
end
