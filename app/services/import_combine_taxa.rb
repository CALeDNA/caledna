# frozen_string_literal: true

module ImportCombineTaxa
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
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

    if name.blank?
      rank = nil
    end

    {

      notes: notes.present? ? notes.join('; ') : nil,
      name: name,
      rank: rank,
      synonym: synonym
    }
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

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
    taxonomy = original_taxonomy.gsub(/^.*?;/, '')
    sql = 'original_taxonomy_phylum = ? OR ' \
      'original_taxonomy_superkingdom = ?'

    CalTaxon.where(sql, taxonomy, taxonomy).first
  end

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
