class AddTimestamps < ActiveRecord::Migration[5.0]
  def up
    add_timestamps :cal_taxa
    add_timestamps :extractions
    # CalTaxon.find_each do |t|
    #   t.update(created_at: Time.zone.now, created_at: Time.zone.now)
    # end
    # Extraction.find_each do |e|
    #   e.update(created_at: Time.zone.now, created_at: Time.zone.now)
    # end
  end

  def down
    remove_timestamps :cal_taxa
    remove_timestamps :extractions
  end
end
