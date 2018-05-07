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

    taxon = find_partial_taxon(hierarchy, rank)

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

  def find_exact_taxon(hierarchy, rank)
    unique_taxon_names = %w[species order class phylum kingdom superkingdom]

    if unique_taxon_names.include?(rank)
      get_unique_taxon(hierarchy, rank)
    elsif rank == 'genus'
      get_genus(hierarchy)
    elsif rank == 'family'
      get_family(hierarchy)
    end
  end

  def find_partial_taxon(hierarchy, rank)
    unique_taxon_names = %w[species order class phylum kingdom superkingdom]

    if unique_taxon_names.include?(rank)
      get_unique_taxon(hierarchy, rank)
    elsif rank == 'genus'
      get_genus(hierarchy, partial: true)
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
  # rubocop:disable Metrics/MethodLength
  def get_family(hierarchy)
    taxon_name = hierarchy[:family].downcase

    query = NcbiNode.joins(:ncbi_names)
                    .where("lower(\"name\") = \'#{taxon_name}\'")
                    .where(rank: 'family')

    if hierarchy[:phylum].present?
      # NOTE: this code searches nested arrays for name and rank
      # 20 grabs 20 nested arrays from lineage
      # [2,3] grabs 2nd item (name) and 3rd item (rank) from each nested array
      sql = "'{#{hierarchy[:phylum]},phylum}'::text[] <@ lineage[20][2:3]"
      query = query.where(sql)
    else
      sql = "'{phylum}'::text[] <@ lineage[20][2:3]"
      query = query.where.not(sql)
    end
    query.take
  end
  # rubocop:enable Metrics/MethodLength

  #  NOTE: genus names are unique to kingdom, phylum, class, order, family
  # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  def get_genus(hierarchy, partial = false)
    taxon_name = hierarchy[:genus].downcase

    query = NcbiNode.joins(:ncbi_names)
                    .where("lower(\"name\") = \'#{taxon_name}\'")
                    .where(rank: 'genus')

    if hierarchy[:kingdom].present?
      sql = "'{#{hierarchy[:kingdom]},kingdom}'::text[] <@ lineage[20][2:3]"
      query = query.where(sql)
    elsif partial == false
      sql = "'{kingdom}'::text[] <@ lineage[20][2:3]"
      query = query.where.not(sql)
    end

    if hierarchy[:phylum].present?
      sql = "'{#{hierarchy[:phylum]},phylum}'::text[] <@ lineage[20][2:3]"
      query = query.where(sql)
    else
      sql = "'{phylum}'::text[] <@ lineage[20][2:3]"
      query = query.where.not(sql)
    end

    if hierarchy[:class].present?
      sql = "'{#{hierarchy[:class]},class}'::text[] <@ lineage[20][2:3]"
      query = query.where(sql)
    else
      sql = "'{class}'::text[] <@ lineage[20][2:3]"
      query = query.where.not(sql)
    end

    if hierarchy[:order].present?
      sql = "'{#{hierarchy[:order]},order}'::text[] <@ lineage[20][2:3]"
      query = query.where(sql)
    else
      sql = "'{order}'::text[] <@ lineage[20][2:3]"
      query = query.where.not(sql)
    end

    if hierarchy[:family].present?
      sql = "'{#{hierarchy[:family]},family}'::text[] <@ lineage[20][2:3]"
      query = query.where(sql)
    else
      sql = "'{family}'::text[] <@ lineage[20][2:3]"
      query = query.where.not(sql)
    end
    query.take
  end
  # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

  def get_unique_taxon(hierarchy, rank)
    taxon_name = hierarchy[rank.to_sym].downcase
    if taxon_name.include?("'")
      taxon_name.gsub!("'", "''")
    end

    # NOTE: ".first" calls order on primary key, ".take" does not
    NcbiNode.joins(:ncbi_names).where("lower(\"name\") = '#{taxon_name}'")
            .where(rank: rank).take
  end
end
# rubocop:enable Metrics/ModuleLength

class TaxaError < StandardError
end
