# frozen_string_literal: true

module WebsiteStats
  def fetch_families_count
    results = conn.exec_query(rank_count('family'))
    results.entries[0]['count']
  end

  def fetch_species_count
    results = conn.exec_query(rank_count('species'))
    results.entries[0]['count']
  end

  def fetch_taxa_count
    results = conn.exec_query(taxa_count_sql)
    results.entries[0]['count']
  end

  private

  def taxa_count_sql
    <<-SQL
      SELECT count(*) FROM (
        SELECT DISTINCT taxon_id
        FROM asvs
        JOIN research_projects
        ON asvs.research_project_id = research_projects.id
        AND research_projects.published = TRUE
      ) AS temp;
    SQL
  end

  def rank_count(rank)
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
        )
      ) AS temp;
    SQL
  end

  def conn
    ActiveRecord::Base.connection
  end
end
