class CreateEventRegistrations < ActiveRecord::Migration[5.2]
  def change
    create_table :event_registrations do |t|
      t.references :user
      t.references :event
      t.string :status_cd

      t.timestamps
    end

    add_index :event_registrations, [:user_id, :event_id], unique: true
  end
end
