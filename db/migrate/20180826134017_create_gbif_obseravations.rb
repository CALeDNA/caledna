class CreateGbifObseravations < ActiveRecord::Migration[5.2]
  def up
    script = Rails.root.join('db').join('data').join('gbif_occurrences_schema.sql')
    execute File.read(script)
  end

  def down
    drop_table 'external.gbif_occurrences'
    execute 'DROP SCHEMA external'
  end
end
