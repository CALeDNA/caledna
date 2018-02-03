class RemoveRolesTables < ActiveRecord::Migration[5.0]
  def change
    drop_table :roles do |t|
    end

    drop_table :researchers_roles do |t|
    end
  end
end
