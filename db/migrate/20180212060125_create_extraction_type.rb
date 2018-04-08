# frozen_string_literal: true

class CreateExtractionType < ActiveRecord::Migration[5.0]
  def change
    create_table :extraction_types do |t|
      t.string :name
      t.timestamps
    end
  end
end
