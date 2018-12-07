# frozen_string_literal: true

module ImportCombineTaxa
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
  def parse_taxon(raw_string)
    parts = raw_string.tr('“', '"').tr('”', '"').split(' ')
    name = parse_taxon_name(parts)

    return if parts.length == 2 && name.nil?

    notes = []
    rank = parts.first.downcase

    if parts.second.start_with?('"') && parts.second.end_with?('"')
      notes.push("#{parts.first} #{parts.second}")
    end

    if parts.length > 2
      note = format_note(parts)
      notes.push(note)
      synonym = parse_synonym(note)
    end
    rank = nil if name.blank?

    {
      notes: notes.present? ? notes.join('; ') : nil,
      name: name,
      rank: rank,
      synonym: synonym
    }
  end
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize

  def create_combine_taxa_taxonomy_string(row)
    row = row.with_indifferent_access
    "#{row['superkingdom']};#{row['kingdom']};#{row['phylum']};" \
    "#{row['class']};#{row['order']};#{row['family']};#{row['genus']};" \
    "#{row['species']}"
  end

  def append_header(path, output_file)
    content = CSV.read(path, headers: true, col_sep: "\t")
    CSV.open(output_file, 'a+') do |csv|
      csv << %w[source taxon_id caledna_taxonomy] + content.headers
    end
  end

  def find_cal_taxon(original_taxonomy)
    taxonomy = original_taxonomy

    sql = 'original_taxonomy_phylum = ? OR ' \
      'original_taxonomy_superkingdom = ?'

    CalTaxon.where(sql, taxonomy, taxonomy).first
  end

  # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
  def fetch_global_names(taxon_name)
    return {} if taxon_name.split(' ').length > 1

    global_names_api = ::GlobalNamesApi.new
    results = global_names_api.names(taxon_name)

    return {} if results['data'].nil?
    return {} if results['data'].first['is_known_name'] == false

    api_results = results['data'].first['results']
    process_api_results(api_results)
  end

  def process_api_results(api_results)
    gbif = nil
    ncbi = nil
    worms = nil
    col = nil
    irmng = nil
    opol = nil

    api_results.each do |api_source_data|
      valid_ids = [11, 4, 9, 1, 8, 179]
      next unless valid_ids.include?(api_source_data['data_source_id'])

      ranks = api_source_data['classification_path_ranks'].downcase.split('|')
      order_index = ranks.index('order') || 1000

      path_parts = api_source_data['classification_path'].split('|')
      order_value = path_parts[order_index] if order_index.present?

      phylum_index = ranks.index('phylum') || 1000
      phylum_value = path_parts[phylum_index] if phylum_index.present?

      string = "p: #{phylum_value}, o: #{order_value}"

      case api_source_data['data_source_title']
      when 'GBIF Backbone Taxonomy' # 11
        gbif = string
      when 'NCBI' # 4
        ncbi = string
      when 'World Register of Marine Species' # 9
        worms = string
      when 'Catalogue of Life' # 1
        col = string
      when 'The Interim Register of Marine and Nonmarine Genera' # 8
        irmng = string
      when 'Open Tree of Life Reference Taxonomy' # 179
        opol = string
      end
    end

    {
      gbif: gbif, ncbi: ncbi, worms: worms, col: col, fungorum: fungorum,
      irmng: irmng, opol: opol
    }
  end
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize

  private

  def format_note(parts)
    parts.join(' ')
  end

  def parse_taxon_name(parts)
    name = parts.second.delete('"')
    return if name.start_with?('N.N.')

    name == name.upcase ? name.titleize : name
  end

  def parse_synonym(synonym_string)
    return unless synonym_string.ends_with?(']')

    name = synonym_string.gsub(/.*? \[="?(.*?)"?\]/, '\1').strip
    name == name.upcase ? name.titleize : name
  end
end
