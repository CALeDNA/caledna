# frozen_string_literal: true

namespace :globi do
  # NOTE: pass in taxon and id through the commandline
  # bin/rake globi:import_by_taxon taxon='Canis lupus' id=2
  task import_by_taxon: :environment do
    taxon = ENV['taxon']
    id = ENV['id']
    offset = ENV['offset']
    return if taxon.nil? || id.nil?

    puts "importing #{taxon}..."

    api = GlobiApi.new
    query = "interactionType=interactsWith&sourceTaxon=#{taxon}"

    request = GlobiRequest.where(url: query, taxon_name: taxon, taxon_id: id)
                          .first_or_create

    query += "&offset=#{offset}&limit=1000"

    response = api.interaction(query)
    results = response.parsed_response

    JSON.parse(results).each do |result|
      attributes = {
        source_taxon_external_id: result['source_taxon_external_id'],
        source_taxon_name: result['source_taxon_name'],
        source_taxon_path: result['source_taxon_path'],
        target_taxon_external_id: result['target_taxon_external_id'],
        target_taxon_name: result['target_taxon_name'],
        target_taxon_path: result['target_taxon_path'],
        interaction_type: result['interaction_type'],
        latitude: result['latitude'],
        longitude: result['longitude'],
        globi_request_id: request.id
      }

      GlobiInteraction.create(attributes)
    end
  end
end
