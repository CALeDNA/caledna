class CreateSurveyAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_answers do |t|
      t.references :survey_question, null: false
      t.references :survey_response, null: false
      t.jsonb :content, null: false, default: {}

      t.timestamps
    end
  end
end
