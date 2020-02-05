class UpdatePrimerSequenceField < ActiveRecord::Migration[5.2]
  def change
    rename_column :primers, :sequence_1, :forward_primer
    rename_column :primers, :sequence_2, :reverse_primer
  end
end
