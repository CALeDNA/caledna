class CreateJoinTablePrimersSamples < ActiveRecord::Migration[5.2]
  def change
    create_join_table :primers, :samples do |t|
      t.index [:primer_id, :sample_id], unique: true
    end
  end
end
