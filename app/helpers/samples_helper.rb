# frozen_string_literal: true

module SamplesHelper
  def self.asvs_count(counts, sample)
    count_data = counts.to_a.select { |c| c['sample_id'] == sample.id }.first
    count_data['count'] if count_data.present?
  end

  def self.threatened?(iucn_status)
    return false if iucn_status.blank?
    statuses = IucnStatus::THREATENED.values

    statuses.include?(iucn_status)
  end
end
