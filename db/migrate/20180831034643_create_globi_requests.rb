class CreateGlobiRequests < ActiveRecord::Migration[5.2]
  def change
    create_table 'external.globi_requests' do |t|
      t.string :url
      t.string :taxon_name
      t.integer :taxon_id
      t.text :location
      t.timestamps
    end

    remove_column 'external.globi_interactions', :url, :string
    add_reference 'external.globi_interactions', 'globi_request',
      foreign_key: { to_table: 'external.globi_requests' }
  end
end
