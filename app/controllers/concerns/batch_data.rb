# frozen_string_literal: true

module BatchData
  extend ActiveSupport::Concern

  private

  def table
    project_id = params['research_project_id'] || params['slug']
    project_id == 'pillar-point' ? 'pillar_point.asvs' : 'asvs'
  end

  def asvs_count
    @asvs_count ||= begin
      sql = <<-SQL
        SELECT sample_id, COUNT(*)
        FROM #{table}
        GROUP BY sample_id
      SQL

      ActiveRecord::Base.connection.exec_query(sql)
    end
  end
end
