class CreateSamples < ActiveRecord::Migration[5.0]
  def change
    create_table :samples do |t|
      t.references :project, foreign_key: true
      t.integer :kobo_id
      t.decimal :latitude, precision: 15, scale: 10
      t.decimal :longitude, precision: 15, scale: 10
      t.datetime :submission_date
      t.string :letter_code
      t.string :bar_code
      t.string :kit_number
      t.jsonb :kobo_data
      t.boolean :approved, default: false
      t.boolean :analyzed, default: false
      t.datetime :analysis_date
      t.text :notes
      t.timestamps
    end
  end
end
