# frozen_string_literal: true

class Create2020NcbiTables < ActiveRecord::Migration[5.2]
  def up
    create_table 'external.ncbi_versions' do |t|
      t.string :name
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
    create_table 'external.ncbi_deleted_taxa' do |t|
      t.integer :taxon_id, index: true
      t.references :ncbi_version, foreign_key: { to_table: 'external.ncbi_versions' }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
    create_table 'external.ncbi_merged_taxa' do |t|
      t.integer :old_taxon_id, index: true
      t.integer :taxon_id, index: true
      t.references :ncbi_version, foreign_key: { to_table: 'external.ncbi_versions' }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end

    rename_table :asvs, :asvs_2017
    execute 'ALTER TABLE asvs_2017 SET SCHEMA external;'
    create_table :asvs do |t|
      t.integer :taxon_id, index: true
      t.references :sample, foreign_key: true
      t.integer :count
      t.references :research_project, foreign_key: true
      t.references :primer, foreign_key: true
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end

    rename_table :ncbi_names, :ncbi_names_2017
    execute 'ALTER TABLE ncbi_names_2017 SET SCHEMA external;'
    create_table :ncbi_names do |t|
      t.integer :taxon_id, index: true
      t.text :name
      t.string :unique_name
      t.string :name_class
      t.references :ncbi_version, foreign_key: { to_table: 'external.ncbi_versions' }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end

    rename_table :ncbi_nodes, :ncbi_nodes_2017
    execute 'ALTER TABLE ncbi_nodes_2017 SET SCHEMA external;'
    create_table 'ncbi_nodes', id: false do |t|
      t.integer :taxon_id, primary_key: true
      t.integer :parent_taxon_id, index: true
      t.string :rank
      t.string :canonical_name

      t.integer :division_id
      t.integer :cal_division_id

      t.text :full_taxonomy_string
      t.integer :ids, default: [], array: true
      t.text :ranks, default: [], array: true
      t.text :names, default: [], array: true

      t.jsonb :hierarchy_names, default: {}
      t.jsonb :hierarchy, default: {}

      t.integer :ncbi_id, index: true
      t.integer :bold_id
      t.string :source, default: :ncbi
      t.references :ncbi_version, foreign_key: { to_table: 'external.ncbi_versions' }

      t.string :alt_names
      t.string :common_names

      t.integer :asvs_count
      t.integer :asvs_count_la_river

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end

  def down
    drop_table :ncbi_nodes
    execute 'ALTER TABLE external.ncbi_nodes_2017 SET SCHEMA public;'
    rename_table :ncbi_nodes_2017, :ncbi_nodes

    drop_table :ncbi_names
    execute 'ALTER TABLE external.ncbi_names_2017 SET SCHEMA public;'
    rename_table :ncbi_names_2017, :ncbi_names

    drop_table :asvs
    execute 'ALTER TABLE external.asvs_2017 SET SCHEMA public;'
    rename_table :asvs_2017, :asvs

    drop_table 'external.ncbi_merged_taxa'
    drop_table 'external.ncbi_deleted_taxa'
    drop_table 'external.ncbi_versions'
  end
end
