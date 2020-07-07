class AddRegistrationRequiredToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :registration_required, :boolean, default: true
  end
end
