class CreateSurveyResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_responses do |t|
      t.references :user, null: false
      t.references :survey, null: false

      t.timestamps
    end
  end
end
