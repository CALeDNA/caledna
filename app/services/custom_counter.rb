# frozen_string_literal: true

module CustomCounter
  def fetch_asv_counts_for(sql)
    conn = ActiveRecord::Base.connection
    conn.exec_query(sql)
  end

  def update_asvs_count
    puts 'reset asvs_count...' if Rails.env.development?
    reset_counter('asvs_count')

    puts 'update asvs_count...' if Rails.env.development?
    results = fetch_asv_counts_for(asvs_count_sql)

    results.each do |result|
      update_count(result['taxon_id'], result['count'])
    end
  end

  def update_asvs_count_la_river
    puts 'update asvs_count_la_river...'
    reset_counter('asvs_count_la_river')

    puts 'update asvs_count_la_river...'
    results = fetch_asv_counts_for(asvs_count_la_river_sql)

    results.each do |result|
      update_count_la_river(result['taxon_id'], result['count'])
    end
  end

  private

  def reset_counter(asvs_field)
    sql = <<~SQL
      UPDATE ncbi_nodes set #{asvs_field} = 0
      WHERE #{asvs_field} > 0
      AND taxon_id IN (SELECT taxon_id FROM ncbi_nodes_edna);
    SQL
    conn.exec_update(sql)
  end

  def hide_threatened
    <<~SQL
      AND (ncbi_nodes.iucn_status IS NULL OR
        ncbi_nodes.iucn_status NOT IN
        ('#{IucnStatus::THREATENED.values.join("','")}')
      )
    SQL
  end

  def asvs_count_sql
    <<-SQL
      SELECT taxon_id, count(*) FROM (
        SELECT unnest(ncbi_nodes.ids) as taxon_id, sample_id
        FROM asvs
        JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
          AND ncbi_nodes.taxon_id IN (SELECT taxon_id FROM asvs)
        JOIN research_projects
          ON asvs.research_project_id = research_projects.id
          AND research_projects.published = TRUE
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
        JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
        JOIN research_projects
          ON asvs.research_project_id = research_projects.id
          AND research_projects.published = TRUE
        where asvs.research_project_id = #{ResearchProject.la_river.id}
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

  def conn
    ActiveRecord::Base.connection
  end
end
