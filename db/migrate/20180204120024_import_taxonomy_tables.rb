# frozen_string_literal: true

class ImportTaxonomyTables < ActiveRecord::Migration[5.0]
  class SchemaMigration < ActiveRecord::Base; self.primary_key = :version; end

  def up
    script = Rails.root.join('db').join('data').join('itis_condensed_schema.sql')
    execute File.read(script)
  end

  def down
    drop_table :hierarchy
    drop_table :kingdoms
    drop_table :longnames
    drop_table :taxon_unit_types
    drop_table :taxonomic_units
    drop_table :vernaculars
  end
end
