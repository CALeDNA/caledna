class CreateWebsites < ActiveRecord::Migration[5.2]
  def change
    create_table :websites do |t|
      t.string :name, null: false

      t.timestamp
    end
  end
end
