class RenameHexbin < ActiveRecord::Migration[5.2]
  def up
    execute 'ALTER TABLE "pour"."hexbin_1km" RENAME TO "hexbin";'
    add_column 'pour.hexbin', :distance, :integer
    execute 'UPDATE pour.hexbin SET distance = 1000;'
  end

  def down
    remove_column 'pour.hexbin', :distance
    execute 'ALTER TABLE "pour"."hexbin" RENAME TO "hexbin_1km";'
  end
end
