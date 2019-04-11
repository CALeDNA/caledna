# frozen_string_literal: true

module SamplesHelper
  def self.kingdom_count(asvs)
    kingdoms = %w[Archaea Animals Bacteria Fungi Plants Viruses]
    results = {}
    kingdoms.each do |kingdom|
      results[kingdom] =
        asvs.select { |asv| asv.ncbi_node.ncbi_division.name == kingdom }.count
    end
    results
  end

  def self.asvs_count(counts, sample)
    count_data = counts.to_a.select { |c| c['sample_id'] == sample.id }.first
    count_data['count'] if count_data.present?
  end

  def self.threatened?(iucn_status)
    return false if iucn_status.blank?
    statuses = IucnStatus::THREATENED.values

    statuses.include?(iucn_status)
  end

  def self.taxonomy_string(lineage)
    [
      rank_name(lineage, 'superkingdom'),
      rank_name(lineage, 'kingdom'),
      rank_name(lineage, 'phylum'),
      rank_name(lineage, 'class'),
      rank_name(lineage, 'order'),
      rank_name(lineage, 'family'),
      rank_name(lineage, 'genus'),
      rank_name(lineage, 'species')
    ].compact.join(', ')
  end

  def self.sorted_taxa(organisms)
    taxa = organisms.map do |o|
      o.attributes.merge(taxonomy_string: taxonomy_string(o.lineage))
    end
    taxa.sort_by { |a| a[:taxonomy_string] }
  end

  def self.rank_info(lineage, rank)
    # lineage is blank for BOLD taxa
    return if lineage.blank?
    lineage.select { |l| l.third == rank }.first
  end

  def self.rank_name(lineage, rank)
    rank_info(lineage, rank).try(:second)
  end

  def self.batch_common_names(vernaculars, taxon_id, parenthesis = true)
    names = vernaculars.to_a
                       .select { |i| i['taxon_id'] == taxon_id }
                       .pluck('name')
    return if names.blank?

    parenthesis ? "(#{common_names_string(names)})" : common_names_string(names)
  end

  def self.common_names_string(names)
    max = 3
    names.count > max ? "#{names.take(max).join(', ')}..." : names.join(', ')
  end
end
