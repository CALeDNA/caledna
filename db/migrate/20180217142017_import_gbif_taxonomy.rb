# frozen_string_literal: true

class ImportGbifTaxonomy < ActiveRecord::Migration[5.0]
  class SchemaMigration < ActiveRecord::Base; self.primary_key = :version; end

  def up
    script = Rails.root.join('db').join('data').join('gbif_schema.sql')
    execute File.read(script)
    # script = Rails.root.join('db').join('data').join('gbif_data.sql')
    # execute File.read(script)
  end

  def down
    drop_table :distributions
    drop_table :multimedia
    drop_table :taxa
    drop_table :vernaculars
  end
end
