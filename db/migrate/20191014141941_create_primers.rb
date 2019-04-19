class CreatePrimers < ActiveRecord::Migration[5.2]
  def up
    create_table :primers do |t|
      t.string :name, null: false
      t.text :sequence_1
      t.text :sequence_2
      t.text :reference

      t.timestamps
    end

    %w[12S 16S 18S PITS FITS CO1 trnL].each do |name|
      Primer.create(name: name)
    end
  end

  def down
    drop_table :primers
  end
end
