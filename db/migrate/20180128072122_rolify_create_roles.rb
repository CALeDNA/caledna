# frozen_string_literal: true

class RolifyCreateRoles < ActiveRecord::Migration[5.0]
  def change
    create_table(:roles) do |t|
      t.string :name
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    create_table(:researchers_roles, :id => false) do |t|
      t.references :researcher
      t.references :role
    end
    
    add_index(:roles, [ :name, :resource_type, :resource_id ])
    add_index(:researchers_roles, [ :researcher_id, :role_id ])
  end
end
