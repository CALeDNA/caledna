# frozen_string_literal: true

class AddAsvCountToTaxon < ActiveRecord::Migration[5.0]
  def change
    add_index :asvs, :taxonID
    add_column :taxa, :asvs_count, :integer, default: 0
    add_index :taxa, :asvs_count
  end
end
