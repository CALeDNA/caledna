class AddForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :asvs, :samples
    add_foreign_key :asvs, :research_projects
    add_foreign_key :event_registrations, :users
    add_foreign_key :event_registrations, :events
    add_foreign_key :events, :field_projects
    add_foreign_key :pages, :research_projects
    add_foreign_key :pages, :websites
    add_foreign_key :site_news, :websites
    add_foreign_key :survey_answers, :survey_questions
    add_foreign_key :survey_answers, :survey_responses
    add_foreign_key :survey_options, :survey_questions
    add_foreign_key :survey_questions, :surveys
    add_foreign_key :survey_responses, :surveys
  end
end
