# frozen_string_literal: true

class AddIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :vernaculars, :language
    add_index :taxa, :datasetID
  end
end
