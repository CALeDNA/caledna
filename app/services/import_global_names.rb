# frozen_string_literal: true

module ImportGlobalNames
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
  def clean_data(results)
    ids = {}

    results.each do |source|
      taxon_id = source['taxon_id']

      case source['data_source_title']
      when 'EOL'
        ids[:eol_id] = taxon_id
      when 'GBIF Backbone Taxonomy'
        ids[:gbif_id] = taxon_id
      when 'iNaturalist'
        ids[:inaturalist_id] = taxon_id
      when 'ITIS'
        ids[:itis_id] = taxon_id
      when 'IUCN Red List of Threatened Species'
        ids[:iucn_id] = taxon_id
      when 'The Mammal Species of The World'
        ids[:msw_id] = taxon_id
      when 'NCBI'
        ids[:ncbi_id] = taxon_id
      when 'World Register of Marine Species'
        ids[:worms_id] = taxon_id
      end
    end

    ids
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength

  def create_external_resource(results, taxon)
    return if results['data'].nil?
    return if results['data'].first['is_known_name'] == false

    filtered_ids = clean_data(results['data'].first['results'])
    filtered_ids[:inaturalist_id] = taxon.taxonID
    filtered_ids[:source] = 'globalnames'

    ExternalResource.create(filtered_ids)
  end
end
