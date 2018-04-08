# frozen_string_literal: true

class CreatePhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :photos do |t|
      t.string :source_url
      t.string :file_name
      t.references :sample, foreign_key: true
      t.jsonb :kobo_payload
      t.timestamps
    end
  end
end
