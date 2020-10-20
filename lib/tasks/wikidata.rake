# frozen_string_literal: true

namespace :wikidata do
  require_relative '../../app/services/wikidata_import'
  include WikidataImport

  def find_dups_for_sql(field)
    <<~SQL
      SELECT ncbi_id, ncbi_name, wiki_title,
      ARRAY_AGG(DISTINCT #{field})
        FILTER (WHERE #{field} IS NOT NULL) AS records
      FROM external_resources
      WHERE  source  = 'wikidata'
      GROUP BY ncbi_id, ncbi_name, wiki_title
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

  task normalize_worms: :environment do
    field = 'worms_id'
    api = WormsApi.new

    sql = find_dups_for_sql(field)
    results = conn.exec_query(sql)
    results.each do |result|
      puts result['ncbi_id']
      response = api.taxa_fuzzy(result['ncbi_name'])
      response = api.taxa_fuzzy(result['wiki_title']) if response.code == 204
      if response.code == 200
        body = JSON.parse(response.body)[0][0]
        taxon_id = body['AphiaID']
      else
        taxon_id = nil
      end
      ExternalResource.where(ncbi_id: result['ncbi_id'])
                      .update(field => taxon_id)
    end
  end

  task normalize_itis: :environment do
    field = 'itis_id'
    api = ItisApi.new

    sql = find_dups_for_sql(field)
    results = conn.exec_query(sql)
    results.each do |result|
      puts result['ncbi_id']

      response = api.taxa(result['ncbi_name'])
      if response['anyMatchList'].blank?
        response = api.taxa(result['wiki_title'])
      end
      if response['anyMatchList'].present?
        match = response['anyMatchList']
                .filter do |t|
          t['sciName'] == result['ncbi_name'] ||
            t['sciName'] == result['wiki_title']
        end.first
        taxon_id = match['tsn']
      else
        taxon_id = nil
      end

      ExternalResource.where(ncbi_id: result['ncbi_id'])
                      .update(field => taxon_id)
    end
  end

  task normalize_gbif: :environment do
    field = 'gbif_id'
    api = GbifApi.new

    sql = find_dups_for_sql(field)
    results = conn.exec_query(sql)
    results.each do |result|
      puts result['ncbi_id']

      response = api.taxa(result['ncbi_name'])
      if response['matchType'] == 'NONE'
        response = api.taxa(result['wiki_title'])
      end
      taxon_id = if response['matchType'] == 'NONE'
                   nil
                 else
                   response['usageKey']
                 end

      ExternalResource.where(ncbi_id: result['ncbi_id'])
                      .update(field => taxon_id)
    end
  end

  task normalize_cnps: :environment do
    field = 'cnps_id'

    ids = {
      '880711' => 208,
      '61574' => 3120,
      '188300' => 695,
      '327346' => 1079,
      '558684' => 3636,
      '863324' => 2213,
      '866992' => 1745,
      '53788' => 1166,
      '2042412' => 960,
      '53789' => 1167
    }
    ids.each do |ncbi_id, target_id|
      puts "#{ncbi_id}, #{target_id}"
      ExternalResource.where(ncbi_id: ncbi_id)
                      .update(field => target_id)
    end
  end

  task normalize_cites: :environment do
    field = 'cites_id'

    ids = {
      '50047' => 68_360
    }
    ids.each do |ncbi_id, target_id|
      puts "#{ncbi_id}, #{target_id}"
      ExternalResource.where(ncbi_id: ncbi_id)
                      .update(field => target_id)
    end
  end

  task normalize_calflora: :environment do
    field = 'calflora_id'

    ids = {
      '880711' => 13_175,
      '221223' => 196,
      '68869' => 13_456,
      '1241237' => 13_145,
      '271007' => 13_479,
      '271018' => 13_483,
      '1041273' => 13_514,
      '270994' => 13_476,
      '244309' => 10_933
    }
    ids.each do |ncbi_id, target_id|
      puts "#{ncbi_id}, #{target_id}"
      ExternalResource.where(ncbi_id: ncbi_id)
                      .update(field => target_id)
    end
  end

  task normalize_eol: :environment do
    field = 'eol_id'
    api = EolApi.new

    sql = find_dups_for_sql(field)
    results = conn.exec_query(sql)
    results.each do |result|
      puts result['ncbi_id']

      response = api.taxa(result['ncbi_name'])
      if response.blank? || response['results'].blank?
        response = api.taxa(result['wiki_title'])
      end
      if response.blank? || response['results'].blank?
        taxon_id = nil
      else
        match = response['results'].filter do |t|
          t['title'] == result['ncbi_name'] ||
            t['title'] == result['wiki_title']
        end.first
        taxon_id = match['id']
      end

      ExternalResource.where(ncbi_id: result['ncbi_id'])
                      .update(field => taxon_id)
    end
  end

  task normalize_inat: :environment do
    field = 'inaturalist_id'
    api = InatApi.new

    sql = find_dups_for_sql(field)
    results = conn.exec_query(sql)
    results.each do |result|
      response = api.taxa_all_names(result['ncbi_name'])
      if response['results'].blank?
        response = api.taxa_all_names(result['wiki_title'])
      end

      if response['results'].blank?
        taxon_id = nil
      elsif result['ncbi_id'] == 102_305
        taxon_id = 50_576
      elsif result['ncbi_id'] == 104_321
        taxon_id = 57_875
      else
        match = response['results'].filter do |t|
          t['name'] == result['ncbi_name'] ||
            t['name'] == result['wiki_title'] ||
            t['matched_term'] == result['ncbi_name'] ||
            t['matched_term'] == result['wiki_title']
        end.first
        if match.blank?
          match = response['results'].filter do |r|
            r['names'].filter do |n|
              n['name'] == result['ncbi_name'] ||
                n['name'] == result['wiki_title']
            end
          end.first
        end
        taxon_id = match['id']
      end

      puts "#{result['ncbi_id']}, #{taxon_id}"

      ExternalResource.where(ncbi_id: result['ncbi_id'])
                      .update(field => taxon_id)
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
