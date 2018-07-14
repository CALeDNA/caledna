class CreateSurveyQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_questions do |t|
      t.text :content, null: false
      t.references :survey, null: false
      t.string :type_cd, null: false

      t.timestamps
    end
  end
end
