# frozen_string_literal: true

class AddHighlightToTaxonomicUnits < ActiveRecord::Migration[5.0]
  def change
    add_column :taxonomic_units, :highlight, :boolean, default: false
  end
end
