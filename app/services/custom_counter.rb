# frozen_string_literal: true

module CustomCounter
  def update_asvs_count
    results = conn.exec_query(asvs_count_sql)
    results.each do |result|
      update_count(result['taxon_id'], result['count'])
    end
  end

  def update_asvs_count_la_river
    results = conn.exec_query(asvs_count_la_river_sql)
    results.each do |result|
      update_count_la_river(result['taxon_id'], result['count'])
    end
  end

  private

  def asvs_count_sql
    <<-SQL
      SELECT taxon_id, count(*) FROM (
        SELECT unnest(ncbi_nodes.ids) as taxon_id, sample_id
        FROM asvs
        JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id"
        JOIN samples ON samples.id = asvs.sample_id
        GROUP BY unnest(ncbi_nodes.ids) , sample_id
      ) AS foo
      GROUP BY foo.taxon_id;
    SQL
  end

  def update_count(taxon_id, count)
    # https://stackoverflow.com/a/24520455
    conn.exec_update(<<-SQL, 'my_query', [[nil, count], [nil, taxon_id]])
      UPDATE ncbi_nodes SET asvs_count = $1 where taxon_id = $2;
    SQL
  end

  def asvs_count_la_river_sql
    <<-SQL
      SELECT taxon_id, count(*) FROM (
        SELECT unnest(ncbi_nodes.ids) as taxon_id, sample_id
        FROM asvs
        JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id"
        JOIN samples ON samples.id = asvs.sample_id
        AND samples.field_data_project_id = #{FieldDataProject::LA_RIVER.id}
        GROUP BY unnest(ncbi_nodes.ids) , sample_id
      ) AS foo
      GROUP BY foo.taxon_id;
    SQL
  end

  def update_count_la_river(taxon_id, count)
    # https://stackoverflow.com/a/24520455
    conn.exec_update(<<-SQL, 'my_query', [[nil, count], [nil, taxon_id]])
      UPDATE ncbi_nodes SET asvs_count_la_river = $1 where taxon_id = $2;
    SQL
  end
end