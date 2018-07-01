# frozen_string_literal: true

module WikidataImport
  require 'sparql/client'

  URL = 'https://query.wikidata.org/sparql'

  def build_queries
    count = fetch_count
    limit = 500_000
    rounds = (count / limit).ceil + 1
    puts "#{count} records..."

    (0...rounds).map do |i|
      build_query(limit, i * limit)
    end
  end

  def import_records
    build_queries.each_with_index do |query, i|
      puts "process query #{i}..."
      delay = i * 3
      ProcessWikidataQueryJob.set(wait: delay.minutes)
                             .perform_later(query.to_json)
    end
  end

  def process_query(query)
    results = client.query(JSON.parse(query))
    process_results(results)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def process_results(results)
    results.each do |result|
      next if external_resource_ids.include?(result[:NCBI_ID]&.value.to_i)

      data = {}
      data[:wikidata_entity] = result[:item].path.split('/').last
      data[:taxon_id] = result[:NCBI_ID]&.value
      data[:eol_id] = result[:Encyclopedia_of_Life_ID]&.value
      data[:bold_id] = result[:BOLD_Systems_taxon_ID]&.value
      data[:calflora_id] = result[:Calflora_ID]&.value
      data[:cites_id] = result[:CITES_Species__ID]&.value
      data[:cnps_id] = result[:CNPS_ID]&.value
      data[:gbif_id] =
        result[:Global_Biodiversity_Information_Facility_ID]&.value
      data[:inaturalist_id] = result[:iNaturalist_taxon_ID]&.value
      data[:itis_id] = result[:ITIS_TSN]&.value
      data[:iucn_id] = result[:IUCN_taxon_ID]&.value
      data[:msw_id] = result[:MSW_ID]&.value
      data[:worms_id] = result[:WoRMS_ID]&.value
      data[:wikidata_image] = result[:image]&.value
      data[:iucn_status] = result[:IUCN_status_label]&.value

      CreateExternalResourceJob.perform_later(data)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def external_resource_ids
    @external_resource_ids ||= ExternalResource.pluck(:taxon_id)
  end

  def create_external_resource(data)
    ExternalResource.where(data).first_or_create
  end

  private

  def fetch_count
    query = 'SELECT (COUNT(*) AS ?count) WHERE { _:b6 p:P685 _:b7. }'
    results = client.query(query)
    results[0][:count].to_i
  end

  # rubocop:disable Metrics/MethodLength
  def build_query(limit, offset)
    # NOTE: can't use FILTER NOT IN to ignore ids because query with 400K+ ids
    # is too large
    parts = <<-'SPARQL'.chop
      SELECT ?item ?NCBI_ID ?Encyclopedia_of_Life_ID ?BOLD_Systems_taxon_ID
      ?Calflora_ID ?CITES_Species__ID ?CNPS_ID
      ?Global_Biodiversity_Information_Facility_ID ?iNaturalist_taxon_ID
      ?ITIS_TSN ?IUCN_taxon_ID ?MSW_ID ?WoRMS_ID ?image
      ?IUCN_conservation_status ?IUCN_status_label
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
        OPTIONAL { ?item wdt:P959 ?MSW_ID. }
        OPTIONAL { ?item wdt:P850 ?WoRMS_ID. }
        OPTIONAL { ?item wdt:P18 ?image. }
        OPTIONAL {
          ?item wdt:P141 ?IUCN_conservation_status.
          ?IUCN_conservation_status rdfs:label ?IUCN_status_label.
          FILTER (lang(?IUCN_status_label) = 'en')
        }
      }
    SPARQL
    parts += "LIMIT #{limit} OFFSET #{offset}"
    parts
  end
  # rubocop:enable Metrics/MethodLength

  def client
    @client ||= SPARQL::Client.new(URL, method: :post)
  end
end