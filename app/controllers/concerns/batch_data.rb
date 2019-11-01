# frozen_string_literal: true

module BatchData
  extend ActiveSupport::Concern

  private

  def asvs_count
    @asvs_count ||= begin
      sql = <<-SQL
        SELECT sample_id, COUNT(*)
        FROM asvs
        GROUP BY sample_id
      SQL

      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
