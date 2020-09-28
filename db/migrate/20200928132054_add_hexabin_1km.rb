class AddHexabin1km < ActiveRecord::Migration[5.2]
  def up
    # https://stackoverflow.com/a/19927748
    source = File.open "db/data/hexbin_1km.sql", "r"
    source.readlines.each do |line|
      line.strip!
      next if line.empty?
      execute line
    end
    source.close
  end

  def down
    drop_table 'pour.hexbin_1km'
  end
end
