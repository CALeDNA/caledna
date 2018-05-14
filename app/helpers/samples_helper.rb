# frozen_string_literal: true

module SamplesHelper
  def self.kingdom_count(asvs)
    kingdoms =
      %w[Animalia Archaea Bacteria Chromista Fungi Plantae Protozoa Viruses]
    results = {}
    kingdoms.each do |kingdom|
      results[kingdom] =
        asvs.select { |asv| asv.ncbi_node.kingdom == kingdom }.count
    end
    results
  end

  def self.asvs_count(counts, sample)
    count_data = counts.to_a.select { |c| c['sample_id'] == sample.id }.first
    count_data['count'] if count_data.present?
  end
end
