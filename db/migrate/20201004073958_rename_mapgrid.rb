class RenameMapgrid < ActiveRecord::Migration[5.2]
  def up
    execute 'ALTER TABLE "pour"."hexbin" RENAME TO "mapgrid";'
    add_column 'pour.mapgrid', :type, :string
  end

  def down
    execute 'ALTER TABLE "pour"."mapgrid" RENAME TO "hexbin";'
    remove_column 'pour.hexbin', :type, :string
  end
end
