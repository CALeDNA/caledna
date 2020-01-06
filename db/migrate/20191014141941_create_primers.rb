class CreatePrimers < ActiveRecord::Migration[5.2]
  def change
    create_table :primers do |t|
      t.string :name, null: false
      t.text :sequence_1
      t.text :sequence_2
      t.text :reference

      t.timestamps
    end
  end
end
