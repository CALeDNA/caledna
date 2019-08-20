class CreateSiteNews < ActiveRecord::Migration[5.2]
  def change
    create_table :site_news do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.boolean :published, default: false
      t.references :website
      t.datetime :published_date
      t.timestamps
    end
  end
end
