class RecreateInatObservationTaxa < ActiveRecord::Migration[5.2]
  def up
    drop_table :inat_observations
    drop_table :inat_taxa

    create_table 'external.inat_taxa', id: false do |t|
      t.bigint :taxon_id, primary_key: true
      t.string :kingdom
      t.string :phylum
      t.string :class_name
      t.string :order
      t.string :family
      t.string :genus
      t.string :species
      t.string :rank
      t.string :canonical_name
      t.string :scientific_name
      t.string :common_name
      t.string :iconic_taxon_name

      t.timestamps
    end

    add_index('external.inat_taxa',
             [:kingdom, :phylum, :class_name, :order, :family, :genus, :species],
             name: 'inat_taxa_all_names_index')
    add_index 'external.inat_taxa', :canonical_name


    create_table 'external.inat_observations', id: false do |t|
      t.bigint :observation_id, primary_key: true
      t.datetime :time_observed_at
      t.integer :user_id
      t.string :user_login
      t.string :quality_grade
      t.string :license
      t.string :url
      t.string :image_url
      t.string :tag_list
      t.string :description
      t.integer :num_identification_agreements
      t.integer :num_identification_disagreements
      t.string :place_guess
      t.numeric :latitude
      t.numeric :longitude
      t.integer :positional_accuracy
      t.boolean :coordinates_obscured
      t.references :taxon, references: :inat_taxa
      t.timestamps
    end
  end

  def down
    remove_index 'external.inat_taxa', name: :inat_taxa_all_names_index
    execute('DROP INDEX "external"."index_external.inat_taxa_on_canonical_name";')
    drop_table 'external.inat_observations'
    drop_table 'external.inat_taxa'

    create_table :inat_observations
    create_table :inat_taxa
  end
end
