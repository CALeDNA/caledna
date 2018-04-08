# frozen_string_literal: true

class CreateHighlights < ActiveRecord::Migration[5.0]
  def change
    create_table :highlights do |t|
      t.string :notes
      t.integer :highlightable_id, index: true
      t.string :highlightable_type, index: true
      t.timestamps
    end
  end
end
