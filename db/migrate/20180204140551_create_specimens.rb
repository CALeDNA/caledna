class CreateSpecimens < ActiveRecord::Migration[5.0]
  def up
    create_table :specimens do |t|
      t.references :sample, foreign_key: true
      t.integer :tsn, index: true
      t.timestamps
    end
    execute 'ALTER TABLE specimens ADD FOREIGN KEY (tsn) REFERENCES taxonomic_units;'
  end

  def down
    drop_table :specimens
  end
end
