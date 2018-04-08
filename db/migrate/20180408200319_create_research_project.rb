# frozen_string_literal: true

class CreateResearchProject < ActiveRecord::Migration[5.0]
  def change
    create_table :research_projects do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
