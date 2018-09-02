class CreateGlobiInteractions < ActiveRecord::Migration[5.2]
  def change
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
  end
end
