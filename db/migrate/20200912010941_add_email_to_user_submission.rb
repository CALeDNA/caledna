class AddEmailToUserSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :user_submissions, :email, :string
  end
end
