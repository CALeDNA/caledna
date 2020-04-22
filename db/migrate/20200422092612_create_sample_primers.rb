class CreateSamplePrimers < ActiveRecord::Migration[5.2]
  def change
    create_table :sample_primers do |t|
      t.references :sample, foreign_key: true
      t.references :primer, foreign_key: true
      t.references :research_project, foreign_key: true
      t.timestamp
    end
  end
end
