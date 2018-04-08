# frozen_string_literal: true

class AddIndexesToTaxonomy < ActiveRecord::Migration[5.0]
  def change
    add_index :taxonomic_units, :complete_name
    add_index :samples, :status_cd
    add_index :taxonomic_units, :n_usage
    add_index :vernaculars, :language
  end
end
