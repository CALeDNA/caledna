# frozen_string_literal: true

module ProcessTestResults
  def find_taxon_from_string(taxonomy_string)
    rank = get_taxon_rank(taxonomy_string)
    hierarchy = get_hierarchy(taxonomy_string)
    taxon = rank && hierarchy ? find_accepted_taxon(hierarchy, rank) : nil
    string = get_complete_taxon_string(taxonomy_string)
    {
      taxon_hierarchy: taxon.try(:hierarchy),
      taxonID: taxon.try(:taxonID),
      rank: rank,
      hierarchy: hierarchy,
      taxonomy_string: string
    }
  end

  def get_taxon_rank(string)
    return if string == 'NA'
    return if string == ';;;;;'

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
    end
  end

  def get_hierarchy(string)
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
    hierarchy[:kingdom] = get_kingdom(taxa[0]) if taxa_present(taxa[0])
    hierarchy
  end

  def find_accepted_taxon(hierarchy, rank)
    taxon = find_exact_taxon(hierarchy, rank)
    # debugger
    return if taxon.nil?

    if taxon.acceptedNameUsageID.present?
      taxon = Taxon.find_by(acceptedNameUsageID: taxon.acceptedNameUsageID)
    end
    taxon
  end

  # NOTE: adds kingdom to taxonomy string since test results don't include kingdom
  def get_complete_taxon_string(string)
    phylum = string.split(';', -1).first
    kingdom = get_kingdom(phylum)
    kingdom.present? ? "#{kingdom};#{string}" : "NA;#{string}"
  end

  private

  def get_kingdom(phylum)
    taxon = Taxon.where(taxonRank: 'phylum', phylum: phylum).first
    taxon.kingdom if taxon.present?
  end

  def taxa_present(taxa)
    taxa.present? &&
      taxa != 'NA' &&
      !taxa.start_with?('uncultured') &&
      !taxa.end_with?('environmental sample') &&
      !taxa.end_with?('sp.')
  end

  def find_exact_taxon(hierarchy, rank)
    unique_taxons = %w[family order class phylum kingdom]

    if unique_taxons.include?(rank)
      get_unique_taxon(hierarchy, rank)
    elsif rank == 'genus'
      get_genus(hierarchy)
    else
      get_species(hierarchy)
    end
  end

  def get_species(hierarchy)
    Taxon.where(
      kingdom: hierarchy[:kingdom],
      canonicalName: hierarchy[:species],
      taxonRank: 'species'
    ).or(Taxon.where(
        kingdom: hierarchy[:kingdom],
        scientificName: hierarchy[:species],
        taxonRank: 'species'
    )).first
  end

  def get_genus(hierarchy)
    Taxon.where(
      kingdom: hierarchy[:kingdom],
      genus: hierarchy[:genus],
      taxonRank: 'genus'
    ).first
  end

  def get_unique_taxon(hierarchy, rank)
    taxon = if hierarchy[:family]
              hierarchy[:family]
            elsif hierarchy[:order]
              hierarchy[:order]
            elsif hierarchy[:class]
              hierarchy[:class]
            elsif hierarchy[:phylum]
              hierarchy[:phylum]
            end
    # debugger
    Taxon.where(canonicalName: taxon, taxonRank: rank).first
  end
end

class TaxaError < StandardError
end

=begin
-- every accepted genus has a unique kingdom
select count(*) , "kingdom", genus
from taxa
where "taxonRank" = 'genus'
and "taxonomicStatus" = 'accepted'
group by  "kingdom", genus
having count(*) > 1;

--  5 animal, 1 plant  species don't have specificEpithet or canonicalName, but have scientitic name
select *
from taxa
where "taxonRank" = 'species'
and "taxonomicStatus" = 'accepted'
and "canonicalName" is null
and "specificEpithet" is null
and kingdom != 'Viruses';

-- 8000  virus, 5 animal, 1 plant  species don't have specificEpithet or canonicalName, but have scientitic name
select count(*), kingdom
from taxa
where "taxonRank" = 'species'
and "taxonomicStatus" = 'accepted'
and "canonicalName" is null
and "specificEpithet" is null
group by  kingdom;

-- only 34 canonicalName have more than one appaearnce when grouped with kingdoms
select count(*) , "canonicalName", kingdom
from taxa
where "taxonRank" = 'species'
and "taxonomicStatus" = 'accepted'
and kingdom  is not null
and "canonicalName"  is not null
group by  "canonicalName",  kingdom
having count(*) > 1;

=end
