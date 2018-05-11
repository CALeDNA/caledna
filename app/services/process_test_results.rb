# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module ProcessTestResults
  # rubocop:disable Metrics/MethodLength
  def find_taxon_from_string(taxonomy_string)
    rank = get_taxon_rank(taxonomy_string)
    hierarchy = get_hierarchy(taxonomy_string, rank)

    raise TaxaError('rank not found') if rank.blank?
    raise TaxaError('hierarchy not found') if hierarchy.blank?

    taxon = find_exact_taxon(hierarchy, rank) || nil
    complete_taxonomy = get_complete_taxon_string(taxonomy_string)
    {
      taxon_hierarchy: taxon.try(:hierarchy),
      taxon_id: taxon.try(:taxon_id),
      rank: rank,
      original_hierarchy: hierarchy,
      complete_taxonomy: complete_taxonomy,
      original_taxonomy: taxonomy_string
    }
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_taxon_rank(string)
    return 'unknown' if string == 'NA'
    return 'unknown' if string == ';;;;;'

    taxa = string.split(';', -1)
    if taxa_present(taxa[5])
      'species'
    elsif taxa_present(taxa[4])
      'genus'
    elsif taxa_present(taxa[3])
      'family'
    elsif taxa_present(taxa[2])
      'order'
    elsif taxa_present(taxa[1])
      'class'
    elsif taxa_present(taxa[0])
      'phylum'
    else
      'unknown'
    end
  end

  def get_hierarchy(string, rank)
    hierarchy = {}
    return hierarchy if string == 'NA'
    return hierarchy if string == ';;;;;'

    taxa = string.split(';', -1)
    hierarchy[:species] = taxa[5] if taxa_present(taxa[5])
    hierarchy[:genus] = taxa[4] if taxa_present(taxa[4])
    hierarchy[:family] = taxa[3] if taxa_present(taxa[3])
    hierarchy[:order] = taxa[2] if taxa_present(taxa[2])
    hierarchy[:class] = taxa[1] if taxa_present(taxa[1])
    hierarchy[:phylum] = taxa[0] if taxa_present(taxa[0])

    taxon = find_exact_taxon(hierarchy, rank, skip_kingdom: true)

    kingdom_superkingdom = get_kingdom_superkingdom(taxon)
    hierarchy[:kingdom] = kingdom_superkingdom[:kingdom]
    hierarchy[:superkingdom] = kingdom_superkingdom[:superkingdom]

    hierarchy
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # NOTE: adds kingdoms to taxonomy string since test results don't include
  # kingdoms
  def get_complete_taxon_string(string)
    rank = get_taxon_rank(string)
    hierarchy = get_hierarchy(string, rank)

    kingdom = hierarchy[:kingdom]
    superkingdom = hierarchy[:superkingdom]

    string = kingdom.present? ? "#{kingdom};#{string}" : ";#{string}"
    string = superkingdom.present? ? "#{superkingdom};#{string}" : ";#{string}"
    string
  end

  def find_extraction_from_barcode(barcode, extraction_type_id)
    sample = find_sample_from_barcode(barcode)

    extraction =
      Extraction
      .where(sample_id: sample.id, extraction_type_id: extraction_type_id)
      .first_or_create

    unless extraction.valid?
      raise TaxaError, "Extraction #{barcode} not created"
    end
    extraction
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def find_sample_from_barcode(barcode)
    samples = Sample.includes(:extractions).where(barcode: barcode)

    if samples.count.zero?
      sample = Sample.create(
        barcode: barcode,
        status_cd: :missing_coordinates,
        field_data_project: FieldDataProject::DEFAULT_PROJECT
      )
      raise TaxaError, "Sample #{barcode} not created" unless sample.valid?

    elsif samples.all?(&:rejected?) || samples.all?(&:duplicate_barcode?)
      raise TaxaError, "Sample #{barcode} was previously rejected"
    elsif samples.count == 1
      sample = samples.take

      unless sample.missing_coordinates?
        sample.update(status_cd: :results_completed)
      end
    else
      temp_samples =
        samples.reject { |s| s.duplicate_barcode? || s.rejected? }

      if temp_samples.count > 1
        raise TaxaError, "multiple samples with barcode #{barcode}"
      end

      sample = temp_samples.first

      unless sample.missing_coordinates?
        sample.update(status_cd: :results_completed)
      end
    end
    sample
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def find_exact_taxon(hierarchy, rank, skip_kingdom: false)
    unique_taxon_names = %w[species order class phylum kingdom superkingdom]

    if unique_taxon_names.include?(rank)
      get_unique_taxon(hierarchy, rank)
    elsif rank == 'genus'
      get_genus(hierarchy, skip_kingdom)
    elsif rank == 'family'
      get_family(hierarchy)
    end
  end

  def get_kingdom_superkingdom(taxon)
    return {} if taxon.blank?
    {
      kingdom: get_kingdom(taxon),
      superkingdom: get_superkingdom(taxon)
    }
  end

  private

  # NOTE: lineage is ["id", "name", "rank"]
  def get_kingdom(taxon)
    taxon.lineage.select { |l| l.third == 'kingdom' }.first.try(:second)
  end

  def get_superkingdom(taxon)
    taxon.lineage.select { |l| l.third == 'superkingdom' }.first.try(:second)
  end

  def taxa_present(taxa)
    taxa.present? && taxa != 'NA'
  end

  #  NOTE: family names are unique to phylums
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def get_family(hierarchy)
    taxon_name = hierarchy[:family].downcase

    query = NcbiNode.joins(:ncbi_names)
                    .where("lower(\"name\") = \'#{taxon_name}\'")
                    .where(rank: 'family')

    if hierarchy[:phylum].present?
      # NOTE: this code searches nested arrays for name and rank
      # 100 grabs 100 nested arrays from lineage
      # [2,3] grabs 2nd item (name) and 3rd item (rank) from each nested array
      sql = "'{#{hierarchy[:phylum]},phylum}'::text[] <@ lineage[100][2:3]"
      query = query.where(sql)
    else
      sql = "'{phylum}'::text[] <@ lineage[100][2:3]"
      query = query.where.not(sql)
    end

    return if query.size > 1
    query.take
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  #  NOTE: genus names are unique to kingdom, phylum, class, order, family
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def get_genus(hierarchy, skip_kingdom = false)
    taxon_name = hierarchy[:genus].downcase

    query = NcbiNode.joins(:ncbi_names)
                    .where("lower(\"name\") = \'#{taxon_name}\'")
                    .where(rank: 'genus')
    if hierarchy[:kingdom].present?
      sql = "'{#{hierarchy[:kingdom]},kingdom}'::text[] <@ lineage[100][2:3]"
      query = query.where(sql)
    elsif skip_kingdom == false
      sql = "'{kingdom}'::text[] <@ lineage[100][2:3]"
      query = query.where.not(sql)
    end

    query = format_lineage_query('phylum', hierarchy, query)
    query = format_lineage_query('class', hierarchy, query)
    query = format_lineage_query('order', hierarchy, query)
    query = format_lineage_query('family', hierarchy, query)

    return if query.size > 1
    query.take
  end
  # rubocop:enable Metrics/MethodLength,  Metrics/AbcSize

  def format_lineage_query(rank, hierarchy, query)
    if hierarchy[rank.to_sym].present?
      sql = "'{#{hierarchy[rank.to_sym]},#{rank}}'::text[] <@ lineage[100][2:3]"
      query.where(sql)
    else
      sql = "'{#{rank}}'::text[] <@ lineage[100][2:3]"
      query.where.not(sql)
    end
  end

  def get_unique_taxon(hierarchy, rank)
    taxon_name = hierarchy[rank.to_sym].downcase
    # NOTE: escape single quotes in sql query by using two single quotes
    taxon_name.gsub!("'", "''") if taxon_name.include?("'")

    taxa = NcbiNode.joins(:ncbi_names)
                   .where("lower(\"name\") = '#{taxon_name}'")
                   .where(rank: rank)
    return if taxa.size > 1
    # NOTE: ".first" calls order on primary key, ".take" does not
    taxa.take
  end
end
# rubocop:enable Metrics/ModuleLength

class TaxaError < StandardError
end
