# frozen_string_literal: true

class DeleteResearchProjectResultsJob < ApplicationJob
  include UpdateViewsAndCache

  queue_as :default

  def update_sample_status
    sql = <<~SQL
      UPDATE samples SET status_cd = 'approved' WHERE id IN (
        SELECT id FROM samples WHERE status_cd = 'results_completed'
        EXCEPT
        SELECT sample_id FROM sample_primers
       );
    SQL

    execute(sql)
  end

  def delete_asv(project_id)
    sql = 'DELETE FROM asvs WHERE research_project_id = $1;'

    bindings = [[nil, project_id]]
    execute(sql, bindings)
  end

  def delete_research_project_sources(project_id)
    sql =
      'DELETE FROM research_project_sources WHERE research_project_id = $1'
    bindings = [[nil, project_id]]
    execute(sql, bindings)
  end

  def delete_sample_primers(project_id)
    sql = 'DELETE FROM sample_primers WHERE research_project_id = $1;'
    bindings = [[nil, project_id]]
    execute(sql, bindings)
  end

  def execute(sql, bindings = [])
    ActiveRecord::Base.connection.exec_query(sql, 'q', bindings)
  end

  def perform(project_id)
    delete_asv(project_id)
    delete_research_project_sources(project_id)
    delete_sample_primers(project_id)
    update_sample_status
    refresh_caledna_website_stats
    refresh_samples_views
    refresh_ncbi_nodes_views
  end
end
