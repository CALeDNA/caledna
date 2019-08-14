# frozen_string_literal: true

namespace :external_resources do
  require_relative '../../app/services/inat_api.rb'
  def api
    ::InatApi.new
  end

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

  task create_resources_for_inat_taxa: :environment do
    sql = <<-SQL
    SELECT canonical_name, taxon_id
    FROM external.inat_taxa
    LEFT JOIN external_resources
      ON external_resources.inaturalist_id = external.inat_taxa.taxon_id
    WHERE external_resources.inaturalist_id IS NULL
    GROUP BY canonical_name, taxon_id;
    SQL

    taxa = conn.exec_query(sql)

    taxa.each do |taxon|
      puts taxon['canonical_name']
      ExternalResource.create(search_term: taxon['canonical_name'],
                              inaturalist_id: taxon['taxon_id'],
                              source: 'iNaturalist')
    end
  end

  desc 'update inat_id for ncbi taxa where canonical_name matches and ' \
    'inat_id is null'
  task update_inat_id_for_ncbi_taxa: :environment do
    sql = <<-SQL
    SELECT  ncbi_nodes.taxon_id as ncbi_id, inat_taxa.taxon_id as inat_id
    FROM external_resources
    JOIN ncbi_nodes on ncbi_nodes.taxon_id = external_resources.ncbi_id
    join ncbi_divisions on ncbi_divisions.id = ncbi_nodes.cal_division_id
    JOIN external.inat_taxa as inat_taxa
      ON inat_taxa.canonical_name = ncbi_nodes.canonical_name
    WHERE external_resources.ncbi_id IS NOT NULL
    AND external_resources.inaturalist_id IS NULL
    and inat_taxa.kingdom = ncbi_divisions.name
    GROUP BY ncbi_nodes.taxon_id, inat_taxa.taxon_id
    SQL

    resources = conn.exec_query(sql)
    resources.each do |resource|
      puts resource['inat_id']

      update_external_resource_inat_id(inat_id: resource['inat_id'],
                                       ncbi_id: resource['ncbi_id'])
    end
  end

  task manually_update_inat_taxa: :environment do
    # set ncbi_id for Stenopelmatus "mahogany"
    sql1 = <<-SQL
    UPDATE external_resources SET ncbi_id=409502, updated_at = now()
    WHERE inaturalist_id = 534019;
    SQL

    # inat Reptilia has 3 ncbi taxa
    sql2 = <<-SQL
    INSERT INTO external_resources
    (ncbi_id , inaturalist_id, created_at, updated_at, source, search_term)
    VALUES(1294634, 26036, now(), now(), 'iNaturalist', 'Reptilia');
    SQL

    # inat Reptilia has 3 ncbi taxa
    sql3 = <<-SQL
    INSERT INTO external_resources
    (ncbi_id , inaturalist_id, created_at, updated_at, source, search_term)
    VALUES(8459, 26036, now(), now(), 'iNaturalist', 'Reptilia');
    SQL

    # change inat_id for Lotus
    sql4 = <<-SQL
    UPDATE external_resources SET inaturalist_id=47436, updated_at = now()
    WHERE ncbi_id = 3867;
    SQL

    # change inat_id for Cornus
    sql5 = <<-SQL
    UPDATE external_resources SET inaturalist_id=47193, updated_at = now()
    WHERE ncbi_id = 4281;
    SQL

    # set ncbi_id for Viburnaceae
    sql6 = <<-SQL
    UPDATE external_resources SET ncbi_id=4206, updated_at = now()
    WHERE inaturalist_id = 781703;
    SQL

    # set ncbi_id for Paradoxornithidae
    sql7 = <<-SQL
    UPDATE external_resources SET ncbi_id=36270, updated_at = now()
    WHERE inaturalist_id = 339898;
    SQL

    # set ncbi_id for Cornu
    sql8 = <<-SQL
    UPDATE external_resources SET ncbi_id=6534, updated_at = now()
    WHERE inaturalist_id = 87634;
    SQL

    # set ncbi_id for Cathartiformes
    sql9 = <<-SQL
    UPDATE external_resources SET ncbi_id=2558200, updated_at = now()
    WHERE inaturalist_id = 559244;
    SQL

    queries = [sql1, sql2, sql3, sql4, sql5, sql6, sql7, sql8, sql9]

    queries.each do |sql|
      conn.exec_query(sql)
    end
  end

  task fix_bad_inat_api_imports: :environment do
    taxa = [
      { name: 'Acmispon', rank: 'genus' },
      { name: 'Cornu', rank: 'genus' },
      { name: 'Malosma laurina', rank: 'species' }
    ]

    taxa.each do |taxon|
      name = taxon[:name]
      rank = taxon[:rank]

      api.get_taxa(name: name, rank: rank) do |results|
        record = results.select do |item|
          item['name'] == name && item['rank'] == rank
        end.first
        next if record.blank?

        InatTaxon.update(
          photo: record['default_photo'],
          wikipedia_url: record['wikipedia_url'],
          ids: record['ancestor_ids'],
          iconic_taxon_name: record['iconic_taxon_name'],
          common_name: record['preferred_common_name'],
          taxon_id: record['id']
        ).where(canonical_name: taxon[:name])
      end
    end
  end

  task add_inat_id_to_ncbi_taxa: :environment do
    sql = <<-SQL
    SELECT ncbi_nodes.rank, ncbi_nodes.canonical_name, ncbi_nodes.taxon_id
    FROM external_resources
    JOIN ncbi_nodes on ncbi_nodes.taxon_id = external_resources.ncbi_id
    WHERE external_resources.ncbi_id IS NOT NULL
    AND external_resources.inaturalist_id IS NULL
    AND ncbi_nodes.rank IN ('phylum', 'class', 'order', 'family')
    AND (
      (ncbi_nodes.hierarchy_names ->> 'superkingdom')::Text = 'Eukaryota'
    )
    GROUP BY ncbi_nodes.rank, ncbi_nodes.canonical_name, ncbi_nodes.taxon_id;
    SQL

    ncbi_taxa = conn.exec_query(sql)
    ncbi_taxa.each do |ncbi_taxon|
      sleep(0.5)
      connect_inat_api(ncbi_taxon)
    end
  end

  private

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def update_external_resource_inat_id(inat_id:, ncbi_id:, note: nil)
    sql = <<-SQL
    UPDATE external_resources
    SET inaturalist_id = #{inat_id},
      updated_at = now(),
      notes = case when "notes" is null or trim("notes")=''
        then '#{note}' else "notes" || '; ' || '#{note}' end
    WHERE ncbi_id = #{ncbi_id}
    AND inaturalist_id IS NULL;
    SQL
    conn.exec_query(sql)
  end
end
