# frozen_string_literal: true

class ChangeTaxonomySource < ActiveRecord::Migration[5.0]
  def change
    remove_column :asvs, :tsn, :integer
    add_column :asvs, :taxonID, :integer

    drop_table :hierarchy
    drop_table :kingdoms
    drop_table :longnames
    drop_table :taxon_unit_types
    drop_table :taxonomic_units
    drop_table :vernaculars
  end
end
