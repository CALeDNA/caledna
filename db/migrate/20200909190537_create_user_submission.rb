class CreateUserSubmission < ActiveRecord::Migration[5.2]
  def change
    create_table :user_submissions do |t|
      t.references :user, foreign_key: true
      t.string :user_display_name, null: false
      t.string :title, null: false
      t.text :user_bio
      t.text :content, null: false
      t.string :media_url
      t.string :twitter
      t.string :facebook
      t.string :instagram
      t.string :twitter
      t.string :website
      t.boolean :approved, default: false
      t.timestamps
    end
  end
end



