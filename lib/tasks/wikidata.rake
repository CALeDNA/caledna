# frozen_string_literal: true

namespace :wikidata do
  require_relative '../../app/services/wikidata_import'
  include WikidataImport

  def find_dups_for_sql(field)
    <<~SQL
      SELECT ncbi_id,
      ARRAY_AGG(DISTINCT #{field})
        FILTER (WHERE #{field} IS NOT NULL) AS records
      FROM external_resources
      WHERE  source  = 'wikidata'
      GROUP BY ncbi_id
      HAVING COUNT(*) > 1 AND
      ARRAY_LENGTH(ARRAY_AGG(DISTINCT #{field})
        FILTER (WHERE #{field} IS NOT NULL), 1) > 1
    SQL
  end

  desc 'import wikidata'
  task create_external_resources: :environment do
    sql = "DELETE FROM external_resources WHERE source = 'wikidata'"
    conn.exec_query(sql)

    import_records
  end

  task add_labels: :environment do
    import_labels
  end

  task add_missing_labels: :environment do
    import_missing_labels
  end

  desc 'when an ncbi_id has multiple wikipedia images, update records to ' \
  'use the same image'
  task normalize_wikidata_images: :environment do
    sql = find_dups_for_sql('wikidata_image')
    results = conn.exec_query(sql)
    results.each do |result|
      puts result['ncbi_id']

      records = YAML.safe_load(result['records']).keys
      ExternalResource.where(ncbi_id: result['ncbi_id']).each do |resource|
        resource.dup_data['wikidata_image'] = records
        resource.wikidata_image = records.first
        resource.save
      end
    end
  end

  task add_ncbi_name: :environment do
    sql = <<~SQL
      UPDATE external_resources SET ncbi_name = temp.canonical_name FROM (
        SELECT  external_resources.ncbi_id, ncbi_nodes.canonical_name
        FROM external_resources
        JOIN ncbi_nodes
        ON ncbi_nodes.ncbi_id = external_resources.ncbi_id
        WHERE  external_resources.source = 'wikidata'
      ) AS temp
      WHERE temp.ncbi_id = external_resources.ncbi_id;
    SQL
    conn.exec_query(sql)
  end


  # if a NCBI_ID is assocciated with multiple images, iNaturalist ID, etc,
  # the wiki data api will return multiple records for that NCBI_ID. Need
  # do delete the duplicate records
  task delete_dup_ncbi_records: :environment do
    def delete_dups(result)
      sql = <<~SQL
        DELETE FROM external_resources WHERE ncbi_id = $1
        AND source = 'wikidata'
        LIMIT $2
      SQL

      binding = [[nil, result['ncbi_id']], [nil, result['count'] - 1]]
      conn.exec_query(sql, 'q', binding)
    end

    def my_update_inat_id(result)
      InatApi.new.get_taxa(name: result['search_term']) do |response|
        inat_id = response.first['id']
        puts "#{inat_id}, #{response.first['name']}"

        resource = ExternalResource
          .where(source: 'wikidata', ncbi_id: result['ncbi_id'])
          .first
        resource.update(inaturalist_id: inat_id)
      end
    end

    find_dups_sql = <<~SQL
      SELECT count(*), ncbi_id, eol_id,bold_id,calflora_id,cites_id,cnps_id,
      gbif_id,itis_id,worms_id,wikidata_image, search_term
      FROM external_resources
      WHERE  source  = 'wikidata'
      GROUP BY ncbi_id, eol_id,bold_id,calflora_id,cites_id, cnps_id,
      gbif_id,itis_id,worms_id,wikidata_image, search_term
      HAVING count(*) > 1
      limit 10
    SQL
    results = conn.exec_query(find_dups_sql)

    results.each do |result|
      puts '---------------------'
      puts "#{result['ncbi_id']}, #{result['search_term']}"
      sleep 1
      # delete_dups(result)
      my_update_inat_id(result)
    end
  end

  def conn
    ActiveRecord::Base.connection
  end
end
