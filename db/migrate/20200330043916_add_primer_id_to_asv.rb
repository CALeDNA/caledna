class AddPrimerIdToAsv < ActiveRecord::Migration[5.2]
  def change
    add_reference :asvs, :primer, foreign_key: { to_table: :primers }
  end
end
