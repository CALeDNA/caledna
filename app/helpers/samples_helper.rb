# frozen_string_literal: true

module SamplesHelper
  # rubocop:disable Metrics/MethodLength
  def self.taxonomy_string(taxon)
    begin
      hierarchy_names = YAML.safe_load(taxon.hierarchy_names)
    rescue StandardError => _e
      return
    end

    [
      taxon.division_name,
      hierarchy_names['phylum'],
      hierarchy_names['class'],
      hierarchy_names['order'],
      hierarchy_names['family'],
      hierarchy_names['genus'],
      hierarchy_names['species']
    ].compact.join(', ')
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def self.hierarchy_string(taxon)
    begin
      hierarchy_names = YAML.safe_load(taxon.hierarchy_names)
    rescue StandardError => _e
      return
    end

    {
      kingdom: taxon.division_name,
      phylum: hierarchy_names['phylum'],
      class: hierarchy_names['class'],
      order: hierarchy_names['order'],
      family: hierarchy_names['family'],
      genus: hierarchy_names['genus'],
      species: hierarchy_names['species']
    }.map do |k, v|
      next if v.blank?

      "#{k}: #{v}"
    end.compact.join(', ')
  end
  # rubocop:enable Metrics/MethodLength

  def self.asvs_count(counts, sample)
    count_data = counts.to_a.select { |c| c['sample_id'] == sample.id }.first
    count_data['count'] if count_data.present?
  end
end
