class CreateSurveyAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_answers do |t|
      t.references :survey_question, null: false
      t.references :survey_response, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
