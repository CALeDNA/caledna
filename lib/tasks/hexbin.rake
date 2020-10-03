# frozen_string_literal: true

namespace :hexbin do
  task import_1000: :environment do
    # https://stackoverflow.com/a/19927748
    source = File.open './lib/tasks/data/hexbin_1km.sql', 'r'
    source.readlines.each do |line|
      line.strip!
      next if line.empty?
      puts line
      ActiveRecord::Base.connection.execute(line)
    end
    source.close
  end
end
