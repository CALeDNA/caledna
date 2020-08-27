# frozen_string_literal: true

module WebsiteStats
  def refresh_samples_map
    sql = 'REFRESH MATERIALIZED VIEW samples_map'

    conn.exec_query(sql)
  end

  def change_websites_update_at
    Website.caledna.touch
    Website.la_river.touch
  end

  def refresh_caledna_website_stats
    families_count = fetch_families_count(pour: false)
    species_count = fetch_species_count(pour: false)
    taxa_count = fetch_taxa_count(pour: false)

    website = Website.find_by(name: 'CALeDNA')
    website.update(families_count: families_count,
                   species_count: species_count,
                   taxa_count: taxa_count)
  end

  def refresh_pour_website_stats
    families_count = fetch_families_count(pour: true)
    species_count = fetch_species_count(pour: true)
    taxa_count = fetch_taxa_count(pour: true)

    website = Website.find_by(name: 'Protecting Our River')
    website.update(families_count: families_count,
                   species_count: species_count,
                   taxa_count: taxa_count)
  end

  private

  def fetch_families_count(pour: false)
    results = conn.exec_query(rank_count_sql('family', pour: pour))
    results.entries[0]['count']
  end

  def fetch_species_count(pour: false)
    results = conn.exec_query(rank_count_sql('species', pour: pour))
    results.entries[0]['count']
  end

  def fetch_taxa_count(pour: false)
    results = conn.exec_query(taxa_count_sql(pour: pour))
    results.entries[0]['count']
  end

  def base_taxa_count_sql
    <<-SQL
      SELECT count(*) FROM (
        SELECT DISTINCT taxon_id
        FROM asvs
        JOIN research_projects
        ON asvs.research_project_id = research_projects.id
        AND research_projects.published = TRUE
    SQL
  end

  def taxa_count_sql(pour: false)
    sql = base_taxa_count_sql
    if pour
      sql += " AND asvs.research_project_id = #{ResearchProject.la_river.id}"
    end
    sql += ') AS temp;'
    sql
  end

  def base_rank_count_sql(rank)
    <<-SQL
      SELECT COUNT(*) FROM (
        SELECT DISTINCT (hierarchy ->> '#{rank}')::int
        FROM ncbi_nodes
        WHERE ncbi_nodes.taxon_id IN (
          SELECT taxon_id
          FROM asvs
          JOIN research_projects
          ON asvs.research_project_id = research_projects.id
          AND research_projects.published = TRUE
    SQL
  end

  def rank_count_sql(rank, pour: false)
    sql = base_rank_count_sql(rank)
    if pour
      sql += "AND asvs.research_project_id = #{ResearchProject.la_river.id}"
    end
    sql += <<~SQL
        )
      ) AS temp;
    SQL
    sql
  end

  def conn
    ActiveRecord::Base.connection
  end
end
