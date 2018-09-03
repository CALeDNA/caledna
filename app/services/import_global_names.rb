# frozen_string_literal: true

module ImportGlobalNames
  SCORE_THRESHOLD = 0.75

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create_external_resource(results:, taxon_id:, id_name:)
    return if results['data'].nil?
    return if results['data'].first['is_known_name'] == false
    api_results = results['data'].first['results']

    attributes = clean_data(api_results)
    attributes[id_name] = taxon_id
    attributes[:source] = 'globalnames'
    attributes[:payload] = results
    attributes[:low_score] = low_score(api_results)
    attributes[:vernaculars] = vernaculars(api_results)
    attributes[:search_term] = results['data'].first['supplied_name_string']

    ExternalResource.create(attributes)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def clean_data(results)
    ids = {}

    processed_sources = []
    results.each do |source|
      taxon_id = source['taxon_id']

      next if processed_sources.include?(taxon_id)
      processed_sources << taxon_id

      case source['data_source_title']
      when 'EOL' # 12
        ids[:eol_id] = taxon_id
      when 'GBIF Backbone Taxonomy' # 11
        ids[:gbif_id] = taxon_id
      when 'iNaturalist' # 180
        ids[:inaturalist_id] = taxon_id
      when 'ITIS' # 3
        ids[:itis_id] = taxon_id
      when 'IUCN Red List of Threatened Species' # 163
        ids[:iucn_id] = taxon_id
      when 'The Mammal Species of The World' # 174
        ids[:msw_id] = taxon_id
      when 'NCBI' # 4
        ids[:ncbi_id] = taxon_id
      when 'World Register of Marine Species' # 9
        ids[:worms_id] = taxon_id
      when 'Catalogue of Life' # 1
        ids[:col_id] = taxon_id
      when 'Wikispecies' # 2
        ids[:wikispecies_id] = taxon_id
      end
    end
    ids
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def low_score(results)
    results.any? do |result|
      result['score'] < SCORE_THRESHOLD
    end
  end

  # rubocop:disable Metrics/AbcSize, Style/MultilineBlockChain
  def vernaculars(results)
    results.flat_map do |result|
      result['vernaculars'].select do |v|
        # rubocop:disable Performance/Casecmp
        v['language'].nil? ||
          v['language'].downcase == 'english' ||
          v['language'].downcase == 'en' ||
          v['language'].downcase == 'eng'
        # rubocop:enable Performance/Casecmp
      end.map { |v| v['name'].downcase }
    end.uniq
  end
  # rubocop:enable Metrics/AbcSize, Style/MultilineBlockChain
end
