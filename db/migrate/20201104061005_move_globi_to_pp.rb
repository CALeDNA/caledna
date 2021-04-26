class MoveGlobiToPp < ActiveRecord::Migration[5.2]
  def up
    execute 'ALTER TABLE external.globi_requests SET SCHEMA pillar_point;'
  end

  def down
    execute 'ALTER TABLE pillar_point.globi_requests SET SCHEMA external;'
  end
end
