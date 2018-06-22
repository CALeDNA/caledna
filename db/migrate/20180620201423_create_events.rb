class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.text :description, null: false
      t.text :location
      t.text :contact
      t.references :field_data_project

      t.timestamps
    end
  end
end
