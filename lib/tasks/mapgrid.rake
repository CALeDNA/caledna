# frozen_string_literal: true

namespace :mapgrid do
  task import_hex_500: :environment do
    execute_sql_file('./lib/tasks/data/hexbin_500m.sql')
    update_geom
    update_coordinates
  end

  task import_hex_1000: :environment do
    execute_sql_file('./lib/tasks/data/hexbin_1km.sql')
    update_geom
    update_coordinates
  end

  task import_hex_1500: :environment do
    execute_sql_file('./lib/tasks/data/hexbin_1500m.sql')
    update_geom
    update_coordinates
  end

  task import_hex_2000: :environment do
    execute_sql_file('./lib/tasks/data/hexbin_2km.sql')
    update_geom
    update_coordinates
  end

  task import_hex_3000: :environment do
    execute_sql_file('./lib/tasks/data/hexbin_3km.sql')
    update_geom
    update_coordinates
  end

  task import_square_500: :environment do
    execute_sql_file('./lib/tasks/data/rect_500m.sql')
    update_geom
    update_coordinates
  end

  task import_square_1000: :environment do
    execute_sql_file('./lib/tasks/data/rect_1km.sql')
    update_geom
    update_coordinates
  end

  task import_square_2000: :environment do
    execute_sql_file('./lib/tasks/data/rect_2km.sql')
    update_geom
    update_coordinates
  end

  task import_square_3000: :environment do
    execute_sql_file('./lib/tasks/data/rect_3km.sql')
    update_geom
    update_coordinates
  end

  def execute_sql_file(file)
    # https://stackoverflow.com/a/19927748
    source = File.open(file, 'r')

    source.readlines.each do |line|
      line.strip!
      next if line.empty?
      print '.'
      ActiveRecord::Base.connection.exec_query(line)
    end
    source.close
  end

  def update_geom
    sql = <<~SQL
      UPDATE pour.mapgrid
      SET geom = ST_Transform(ST_SetSRID(geom_projected, #{Geospatial::SRID_PROJECTED}),
                             #{Geospatial::SRID})
      WHERE geom IS NULL;
    SQL
    ActiveRecord::Base.connection.exec_query(sql)
  end

  def update_coordinates
    sql = <<~SQL
      UPDATE pour.mapgrid SET longitude = ST_X(ST_Centroid(geom)),
      latitude = ST_Y(ST_Centroid(geom))
      WHERE longitude IS NULL;
    SQL
    ActiveRecord::Base.connection.exec_query(sql)
  end
end
