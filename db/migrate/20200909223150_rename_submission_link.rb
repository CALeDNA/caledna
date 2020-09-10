class RenameSubmissionLink < ActiveRecord::Migration[5.2]
  def change
    add_column :user_submissions, :embed_code, :string
  end
end
