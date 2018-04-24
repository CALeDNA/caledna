class AddTimestamps < ActiveRecord::Migration[5.0]
  def change
    add_timestamps :cal_taxa, default: DateTime.now
    add_timestamps :extractions, default: DateTime.now
  end
end
