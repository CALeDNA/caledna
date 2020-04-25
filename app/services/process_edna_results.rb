# frozen_string_literal: true

module ProcessEdnaResults
  # rubocop:disable Metrics/CyclomaticComplexity
  def invalid_taxon?(taxonomy_string, strict: true)
    return true if taxonomy_string == 'NA'
    return true if taxonomy_string.split(';').blank?
    if strict && taxonomy_string.split(';', -1).uniq.sort == ['', 'NA']
      return true
    end

    parts_count = taxonomy_string.split(';', -1).count
    return true if parts_count < 6
    return true if parts_count > 7
    false
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def format_result_taxon_data_from_string(taxonomy_string)
    rank = get_taxon_rank(taxonomy_string)
    hierarchy = get_hierarchy(taxonomy_string)
    taxon_data = taxon_data_from_string(taxonomy_string, rank, hierarchy)
    return taxon_data if hierarchy == {}

    taxa = find_existing_taxa(hierarchy, rank).to_a
    if taxa&.size == 1
      taxon_data = taxon_data_from_found_taxon(taxa.first, taxon_data)
    end
    taxon_data
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
  def filtered_ranks(hierarchy, include_lowest:)
    all_ranks = %i[superkingdom kingdom phylum class order family genus species]
    lowest = hierarchy.keys.sort_by { |k| all_ranks.index(k) }.reverse[0, 2]
    add_more_lower = [hierarchy[:phylum], hierarchy[:superkingdom],
                      hierarchy[:class]].all?(&:blank?)
    add_class =
      (hierarchy[:superkingdom].blank? && hierarchy[:phylum].blank?) &&
      hierarchy[:class].present?

    add_phlyum =
      (hierarchy[:phylum].present? && hierarchy[:superkingdom].blank?) ||
      (lowest[0] == :genus && hierarchy[:phylum].present?)

    ranks = []
    ranks << :superkingdom if hierarchy[:superkingdom].present?
    ranks << :phylum if add_phlyum
    ranks << :class if add_class

    ranks << lowest[1] if add_more_lower
    ranks << lowest[0] if include_lowest || hierarchy.size == 1

    ranks.compact.uniq
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity

  def find_existing_taxa(hierarchy, target_rank)
    name = hierarchy[target_rank.to_sym]
    ranks_no_lowest = filtered_ranks(hierarchy, include_lowest: false)
    hierarchy_no_lowest = filtered_hierarchy(hierarchy, ranks_no_lowest)
    filtered_ranks = filtered_ranks(hierarchy, include_lowest: true)
    filtered_hierarchy = filtered_hierarchy(hierarchy, filtered_ranks)

    taxa = find_taxa_by_canonical_name(name, filtered_hierarchy, target_rank)
    return taxa if taxa.present?

    taxa = find_taxa_with_quotes(name, hierarchy_no_lowest, target_rank)
    return taxa if taxa.present?

    find_taxa_by_ncbi_names(name, hierarchy_no_lowest, target_rank)
  end

  def find_result_taxon_from_string(string)
    clean_string = remove_na(string)
    rank = if phylum_taxonomy_string?(clean_string)
             get_taxon_rank_phylum(clean_string)
           else
             get_taxon_rank_superkingdom(clean_string)
           end

    ResultTaxon.where(clean_taxonomy_string: clean_string)
               .where(taxon_rank: rank).first
  end

  # rubocop:disable Metrics/MethodLength
  def phylum_taxonomy_string?(string)
    parts = string.split(';', -1)
    if parts.length == 6
      true
    elsif parts.length == 7
      false
    elsif string == 'NA'
      false
    elsif string == ';;;;;;'
      false
    elsif string == ';;;;;;;'
      false
    else
      raise TaxaError, "#{string}: invalid taxonomy string"
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_taxon_rank_phylum(string)
    return 'unknown' if string == 'NA'
    return 'unknown' if string == ';;;;;'

    clean_taxonomy = remove_na(string)
    taxa = clean_taxonomy.split(';', -1)
    if taxa[5].present?
      'species'
    elsif taxa[4].present?
      'genus'
    elsif taxa[3].present?
      'family'
    elsif taxa[2].present?
      'order'
    elsif taxa[1].present?
      'class'
    elsif taxa[0].present?
      'phylum'
    else
      'unknown'
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_hierarchy_phylum(string)
    hierarchy = {}
    return hierarchy if string == 'NA'
    return hierarchy if string == ';;;;;'

    clean_taxonomy = remove_na(string)
    taxa = clean_taxonomy.split(';', -1)
    hierarchy[:species] = taxa[5] if taxa[5].present?
    hierarchy[:genus] = taxa[4] if taxa[4].present?
    hierarchy[:family] = taxa[3] if taxa[3].present?
    hierarchy[:order] = taxa[2] if taxa[2].present?
    hierarchy[:class] = taxa[1] if taxa[1].present?
    hierarchy[:phylum] = taxa[0] if taxa[0].present?
    hierarchy
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_taxon_rank_superkingdom(string)
    return 'unknown' if string == 'NA'
    return 'unknown' if string == ';;;;;;'

    clean_taxonomy = remove_na(string)
    taxa = clean_taxonomy.split(';', -1)
    if taxa[6].present?
      'species'
    elsif taxa[5].present?
      'genus'
    elsif taxa[4].present?
      'family'
    elsif taxa[3].present?
      'order'
    elsif taxa[2].present?
      'class'
    elsif taxa[1].present?
      'phylum'
    elsif taxa[0].present?
      'superkingdom'
    else
      'unknown'
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_hierarchy_superkingdom(string)
    hierarchy = {}
    return hierarchy if string == 'NA'
    return hierarchy if string == ';;;;;;'

    clean_taxonomy = remove_na(string)
    taxa = clean_taxonomy.split(';', -1)
    hierarchy[:species] = taxa[6] if taxa[6].present?
    hierarchy[:genus] = taxa[5] if taxa[5].present?
    hierarchy[:family] = taxa[4] if taxa[4].present?
    hierarchy[:order] = taxa[3] if taxa[3].present?
    hierarchy[:class] = taxa[2] if taxa[2].present?
    hierarchy[:phylum] = taxa[1] if taxa[1].present?
    hierarchy[:superkingdom] = taxa[0] if taxa[0].present?
    hierarchy
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def find_sample_from_barcode(barcode, status)
    samples = Sample.where(barcode: barcode)

    if samples.length.zero?
      sample = Sample.create(
        barcode: barcode,
        status_cd: status,
        missing_coordinates: true,
        field_project: FieldProject::DEFAULT_PROJECT
      )

      raise TaxaError, "Sample #{barcode} not created" unless sample.valid?

    elsif samples.all?(&:rejected?) || samples.all?(&:duplicate_barcode?)
      raise TaxaError, "Sample #{barcode} was previously rejected"
    elsif samples.length == 1
      sample = samples.take
      sample.update(status_cd: status)
    else
      valid_samples =
        samples.reject { |s| s.duplicate_barcode? || s.rejected? }

      if valid_samples.length > 1
        raise TaxaError, "multiple samples with barcode #{barcode}"
      end

      sample = valid_samples.first
      sample.update(status_cd: status)
    end
    sample
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def convert_raw_barcode(cell)
    parts = cell.split('.')
    sample = parts[0]
    ksample = sample.tr('_', '-')
    # return nil

    # NOTE: KxxxxLS, barcode v1
    if /^[K]?\d{1,4}[ABC][12]$/i.match?(ksample)
      match = /(\d{1,4})([ABC])([12])/i.match(ksample)
      kit = match[1].rjust(4, '0')
      location_letter = match[2]
      sample_number = match[3]
      "K#{kit}-L#{location_letter}-S#{sample_number}".upcase

    # NOTE: Kxxxx-L-S, barcode v1
    elsif /^[K]\d{1,4}-L[ABC]-S[12]$/i.match?(ksample)
      match = /(\d{1,4})-L([ABC])-S([12])/i.match(ksample)
      kit = match[1].rjust(4, '0')
      location_letter = match[2]
      sample_number = match[3]
      "K#{kit}-L#{location_letter}-S#{sample_number}".upcase

    # NOTE: PPxxxxA1, Pillar Point, barcode v1
    elsif /^PP\d{1,4}[ABC][12]$/i.match?(ksample)
      match = /(\d{1,4})([ABC])([12])/i.match(ksample)
      kit = match[1].rjust(4, '0')
      location_letter = match[2]
      sample_number = match[3]
      "K#{kit}-L#{location_letter}-S#{sample_number}".upcase

    # NOTE: Kxxxx-A1, barcode v2
    # rubocop:disable Metrics/LineLength
    elsif /^[K]\d{1,4}-((A1)|(B2)|(C3)|(E4)|(G5)|(K6)|(L7)|(M8)|(T9))$/i.match?(ksample)
      match = /(\d{1,4})-(\w\d)/i.match(ksample)
      kit = match[1].rjust(4, '0')
      sample_number = match[2]
      "K#{kit}-#{sample_number}".upcase
    # rubocop:enable Metrics/LineLength

    # NOTE: ASWS-A1 or MWWS-A1, barcode v2
    elsif /^((ASWS)|(MWWS))-(\w\d)$/i.match?(ksample)
      match = /(\w{4})-(\w\d)/i.match(ksample)
      kit = match[1]
      sample_number = match[2]
      "#{kit}-#{sample_number}".upcase

    # NOTE: neg or blank
    elsif /(neg)|(blank)/i.match?(cell)
      nil

    elsif /^sum.taxonomy$/i.match?(cell)
      nil

    elsif /^sum$/i.match?(cell)
      nil

    else
      sample
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def form_barcode(raw_string)
    raw_barcode = raw_string.strip

    # handles "K0030 B1"
    if raw_barcode.include?(' ')
      parts = raw_barcode.split(' ')
      kit = parts.first
      location_letter = parts.second.split('').first
      sample_number = parts.second.split('').second
      "#{kit}-L#{location_letter}-S#{sample_number}"

    # handles "K0030B1"
    elsif /^K\d{4}\w\d$/.match?(raw_barcode)
      match = /(K\d{4})(\w)(\d)/.match(raw_barcode)
      kit = match[1]
      location_letter = match[2]
      sample_number = match[3]
      "#{kit}-L#{location_letter}-S#{sample_number}"
    else
      raw_barcode
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def find_canonical_taxon_from_string(taxonomy_string)
    new_string = remove_na(taxonomy_string)
    new_string.split(';').last || new_string
  end

  def remove_na(taxonomy_string)
    new_string = taxonomy_string.dup
    new_string.gsub!(/;NA;/, ';;') while new_string.include?(';NA;')
    new_string.gsub!(/;NA$/, ';')
    new_string.gsub!(/^NA;/, ';')
    new_string
  end

  def process_barcodes_for_csv_table(data, barcode_field)
    existing_barcodes = []
    new_barcodes = []

    data.entries.each do |row|
      barcode = row[barcode_field]
      next if barcode.blank?

      sample = Sample.find_by(barcode: barcode)
      sample.present? ? existing_barcodes << barcode : new_barcodes << barcode
    end
    { existing_barcodes: existing_barcodes, new_barcodes: new_barcodes }
  end

  private

  def get_taxon_rank(taxonomy_string)
    if phylum_taxonomy_string?(taxonomy_string)
      get_taxon_rank_phylum(taxonomy_string)
    else
      get_taxon_rank_superkingdom(taxonomy_string)
    end
  end

  def get_hierarchy(taxonomy_string)
    if phylum_taxonomy_string?(taxonomy_string)
      get_hierarchy_phylum(taxonomy_string)
    else
      get_hierarchy_superkingdom(taxonomy_string)
    end
  end

  def get_kingdom(taxon)
    taxon.hierarchy_names['kingdom']
  end

  def get_superkingdom(taxon)
    taxon.hierarchy_names['superkingdom']
  end

  def find_taxa_with_quotes(name, filtered_hierarchy, rank = nil)
    sql = "lower(REPLACE(canonical_name, '''', '')) = ?"
    taxa = NcbiNode.where(sql, name.downcase)
                   .where('hierarchy_names @> ?', filtered_hierarchy.to_json)
    taxa.where(rank: rank) if rank
  end

  def find_taxa_by_canonical_name(name, filtered_hierarchy, rank = nil)
    taxa = NcbiNode.where('lower(canonical_name) = ?', name.downcase)
                   .where('hierarchy_names @> ?', filtered_hierarchy.to_json)
    taxa.where(rank: rank) if rank
  end

  def find_taxa_by_ncbi_names(name, filtered_hierarchy, rank = nil)
    taxa = NcbiNode.joins('JOIN ncbi_names ON ncbi_names.taxon_id = ' \
                          'ncbi_nodes.ncbi_id')
                   .where("ncbi_names.name_class IN ('in-part', 'includes', " \
                          "'scientific name', 'equivalent name','synonym')")
                   .where('ncbi_names.name = ?', name)
                   .where('hierarchy_names @> ?', filtered_hierarchy.to_json)
    taxa.where(rank: rank) if rank
  end

  def find_taxa_with_valid_rank(taxa, hierarchy, rank)
    taxa.select do |t|
      t.hierarchy_names[rank] == hierarchy[rank.to_sym]
    end
  end

  # rubocop:disable Metrics/MethodLength
  def taxon_data_from_string(taxonomy_string, rank, hierarchy)
    {
      taxon_id: nil,
      taxon_rank: rank,
      hierarchy: hierarchy,
      original_taxonomy_string: [taxonomy_string],
      clean_taxonomy_string: remove_na(taxonomy_string),
      ncbi_id: nil,
      bold_id: nil,
      ncbi_version_id: nil,
      canonical_name: find_canonical_taxon_from_string(taxonomy_string)
    }
  end
  # rubocop:enable Metrics/MethodLength

  def taxon_data_from_found_taxon(taxon, taxon_data)
    taxon_data[:taxon_id] = taxon.taxon_id
    taxon_data[:ncbi_id] = taxon.ncbi_id
    taxon_data[:bold_id] = taxon.bold_id
    taxon_data[:ncbi_version_id] = taxon.ncbi_version_id
    taxon_data
  end

  def filtered_hierarchy(hierarchy, ranks)
    hierarchy.select { |k, _v| ranks.include?(k) }
  end
end

class TaxaError < StandardError
end
