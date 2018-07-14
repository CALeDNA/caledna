class AddOrderToSurveyQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :survey_questions, :order_number, :integer
  end
end
