# frozen_string_literal: true

module WikidataImport
  require 'sparql/client'

  URL = 'https://query.wikidata.org/sparql'
  DEBUG_OFFSET = 0
  LIMIT = 6000
  DELAY = 3.minutes

  def import_records
    build_data_queries.each_with_index do |query, i|
      puts "process query #{i}..."
      ProcessWikidataDataJob.set(wait: DELAY * i)
                            .perform_later(query.to_json)
    end
  end

  def import_labels
    build_label_queries.each_with_index do |query, i|
      puts "process query #{i}..."
      ProcessWikidataLabelJob.set(wait: 90.seconds * i)
                             .perform_later(query.to_json)
    end
  end

  def import_missing_labels
    sql = resources_with_labels_sql
    results = ActiveRecord::Base.connection.exec_query(sql)

    results.each_with_index do |result, i|
      ProcessWikidataMissingLabelJob.set(wait: 1.seconds * i)
                                    .perform_later(result['wikidata_entity'])
    end
  end

  private

  def build_data_queries
    count = fetch_count - DEBUG_OFFSET
    rounds = (count / LIMIT).ceil + 1
    puts "#{count} records..."

    (0...rounds).map do |i|
      build_data_query(LIMIT, i * LIMIT + DEBUG_OFFSET)
    end
  end

  def build_label_queries
    count = fetch_count - DEBUG_OFFSET
    rounds = (count / LIMIT).ceil + 1
    puts "#{count} records..."

    (0...rounds).map do |i|
      build_label_query(LIMIT, i * LIMIT + DEBUG_OFFSET)
    end
  end

  def process_wikidata_data(query)
    results = client.query(JSON.parse(query))
    process_data_results(results)
  end

  def process_wikidata_label(query)
    results = client.query(JSON.parse(query))
    process_label_results(results)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def process_data_results(results)
    results.each do |raw|
      result = raw.to_h
      data = {}
      data[:source] = 'wikidata'
      data[:wikidata_entity] = result[:item].path.split('/').last
      data[:ncbi_id] = result[:NCBI_ID]&.value
      data[:eol_id] = result[:Encyclopedia_of_Life_ID]&.value
      data[:bold_id] = result[:BOLD_Systems_taxon_ID]&.value
      data[:calflora_id] = result[:Calflora_ID]&.value
      data[:cites_id] = result[:CITES_Species__ID]&.value
      data[:cnps_id] = result[:CNPS_ID]&.value
      data[:gbif_id] =
        result[:Global_Biodiversity_Information_Facility_ID]&.value
      data[:inaturalist_id] = result[:iNaturalist_taxon_ID]&.value
      data[:itis_id] = result[:ITIS_TSN]&.value
      data[:worms_id] = result[:WoRMS_ID]&.value
      data[:wikidata_image] = result[:image]&.value
      data[:wiki_title] = result[:itemLabel]&.value
      data[:search_term] = result[:itemLabel]&.value

      CreateExternalResourceJob.perform_later(data)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def create_external_resource(data)
    ExternalResource.where(data).first_or_create
  end

  def process_label_results(results)
    results.each do |result|
      entity = result[:item].path.split('/').last
      label = result[:itemLabel]&.value
      UpdateExternalResourceJob.perform_later(entity, label)
    end
  end

  def update_external_resource(entity, label)
    ExternalResource.where(wikidata_entity: entity)
                    .where('search_term is null')
                    .update(search_term: label, wiki_title: label)
  end

  def resources_with_labels_sql
    <<~SQL
      SELECT wikidata_entity
      FROM external_resources
      WHERE external_resources.source = 'wikidata'
      AND search_term IS NULL
      AND wikidata_entity IS NOT NULL;
    SQL
  end

  def process_wikidata_missing_label(entity)
    results = WikidataApi.new.label(entity)
    return if results['entities'].blank?
    return if results['entities'][entity]['labels'].blank?
    return if results['entities'][entity]['labels']['en'].blank?

    label = results['entities'][entity]['labels']['en']['value']
    update_external_resource(entity, label)
  end

  def fetch_count
    query = 'SELECT (COUNT(*) AS ?count) WHERE { _:b6 p:P685 _:b7. }'
    results = client.query(query)
    results[0][:count].to_i
  end

  def build_data_query(limit, offset)
    # NOTE: can't use FILTER NOT IN to ignore ids because query with 400K+ ids
    # is too large.
    <<-SPARQL.chop
      SELECT ?item ?NCBI_ID ?Encyclopedia_of_Life_ID ?BOLD_Systems_taxon_ID
      ?Calflora_ID ?CITES_Species__ID ?CNPS_ID
      ?Global_Biodiversity_Information_Facility_ID ?iNaturalist_taxon_ID
      ?ITIS_TSN ?IUCN_taxon_ID ?WoRMS_ID ?image
       WHERE {
        ?item wdt:P685 ?NCBI_ID.
        OPTIONAL { ?item wdt:P830 ?Encyclopedia_of_Life_ID. }
        OPTIONAL { ?item wdt:P3606 ?BOLD_Systems_taxon_ID. }
        OPTIONAL { ?item wdt:P3420 ?Calflora_ID. }
        OPTIONAL { ?item wdt:P2040 ?CITES_Species__ID. }
        OPTIONAL { ?item wdt:P4194 ?CNPS_ID. }
        OPTIONAL { ?item wdt:P846 ?Global_Biodiversity_Information_Facility_ID. }
        OPTIONAL { ?item wdt:P3151 ?iNaturalist_taxon_ID. }
        OPTIONAL { ?item wdt:P815 ?ITIS_TSN. }
        OPTIONAL { ?item wdt:P627 ?IUCN_taxon_ID. }
        OPTIONAL { ?item wdt:P850 ?WoRMS_ID. }
        OPTIONAL { ?item wdt:P18 ?image. }
      } LIMIT #{limit} OFFSET #{offset}
    SPARQL
  end

  def build_label_query(limit, offset)
    # NOTE: The label query can be very slow, so it is a separate query
    <<-SPARQL.chop
      SELECT ?item ?NCBI_ID ?itemLabel  WHERE {
        {
          SELECT ?item ?NCBI_ID  WHERE {
              ?item wdt:P685 ?NCBI_ID.
          } LIMIT #{limit} OFFSET #{offset}
        }
        SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
      }
    SPARQL
  end

  def build_missing_labels_query(qid)
    <<~Q
      SELECT distinct ?item ?itemLabel WHERE {
        BIND(wd:#{qid} AS ?item).
        SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
      } LIMIT 1
    Q
  end

  def client
    @client ||= SPARQL::Client.new(URL, method: :post)
  end
end

# optional wikipedia and wikispecies artcles causes a time out
#
#          OPTIONAL {?wikispecies schema:about ?item;
#           schema:isPartOf <https://species.wikimedia.org/> .}
#         OPTIONAL {?wikipedia schema:about ?item;
#           schema:isPartOf <https://en.wikipedia.org/>. }
