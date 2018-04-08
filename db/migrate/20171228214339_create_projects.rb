# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.string :kobo_name
      t.integer :kobo_id
      t.jsonb :kobo_payload
      t.datetime :start_date
      t.timestamps

      t.index :kobo_id, unique: true
    end
  end
end
