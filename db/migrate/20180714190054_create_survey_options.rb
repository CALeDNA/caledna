class CreateSurveyOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_options do |t|
      t.text :content, null: false
      t.references :survey_question, null: false
      t.boolean :accepted_answer, default: false, null: false

      t.timestamps
    end
  end
end
