class AddCanContactToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :can_contact, :boolean, default: false, null: false
    users = User.where('confirmed_at IS NOT NULL')
    users.update(can_contact: true)
  end

  def down
    remove_column :users, :can_contact
  end
end
