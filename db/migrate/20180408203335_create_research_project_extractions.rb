# frozen_string_literal: true

class CreateResearchProjectExtractions < ActiveRecord::Migration[5.0]
  def change
    create_table :research_project_extractions do |t|
      t.references :research_project, foreign_key: true
      t.references :extraction, foreign_key: true

      t.timestamps
    end
  end
end
