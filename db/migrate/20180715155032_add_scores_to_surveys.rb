class AddScoresToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :survey_responses, :total_score, :integer, default: 0
    add_column :survey_answers, :score, :integer, default: 0
    add_column :surveys, :passing_score, :integer, default: 0
    add_column :survey_responses, :passed, :boolean, default: false
  end
end
