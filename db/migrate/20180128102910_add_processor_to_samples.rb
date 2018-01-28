class AddProcessorToSamples < ActiveRecord::Migration[5.0]
  def change
    add_reference :samples, :processor, foreign_key: { to_table: :researchers }
  end
end
