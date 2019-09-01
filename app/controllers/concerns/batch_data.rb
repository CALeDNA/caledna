# frozen_string_literal: true

module BatchData
  extend ActiveSupport::Concern

  private

  def asvs_count(sample_id = nil)
    sql = 'SELECT sample_id, COUNT(*) ' \
          'FROM asvs ' \
          'GROUP BY sample_id '
    sql += "WHERE sample_id = #{sample_id}" if sample_id
    @asvs_count ||= ActiveRecord::Base.connection.execute(sql)
  end
end
