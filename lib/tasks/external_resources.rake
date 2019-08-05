# frozen_string_literal: true

namespace :external_resouces do
  task update_icun_status_for_dup_taxa: :environment do
    # change iucn_status for records where ncbi_id occur
    # more than once and one record has not null iucn_status;
    # (ncbi_id = 1, iucn_status = null) and (ncbi_id = 1, iucn_status = 'value')
    # => ncbi_id = 1, iucn_status = 'value'

    #  select count(*), ncbi_id, (ARRAY_AGG(distinct(iucn_status::text)))
    #  from external_resources
    #  group by ncbi_id
    #  having count(ncbi_id) > 1;

    sql = <<-SQL
      UPDATE external_resources
      SET iucn_status = subquery.iucn_status
      FROM (
        SELECT ncbi_id, iucn_status
        FROM external_resources
        WHERE ncbi_id IN (
          SELECT ncbi_id
          FROM external_resources
          GROUP BY ncbi_id
          HAVING count(ncbi_id) > 1
        )
        AND external_resources.iucn_status IS NOT NULL
      ) AS subquery
      WHERE external_resources.ncbi_id = subquery.ncbi_id
      AND external_resources.iucn_status IS NULL;
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end
end
