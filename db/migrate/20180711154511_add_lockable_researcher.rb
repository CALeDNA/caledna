class AddLockableResearcher < ActiveRecord::Migration[5.2]
  def change
    add_column :researchers, :failed_attempts, :integer, default: 0, null: false
    add_column :researchers, :unlock_token, :string
    add_column :researchers, :locked_at, :datetime

    add_index :researchers, :unlock_token, unique: true
  end
end
