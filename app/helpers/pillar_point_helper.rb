# frozen_string_literal: true

module PillarPointHelper
  def self.check_or_x(boolean)
    if boolean
      '<span style="font-size: 20px; color: green;">'\
        '<i class="fas fa-check-circle"></i>'\
      '</span>'
    else
      '<span style="font-size: 20px; color: red;">'\
        '<i class="fas fa-times-circle"></i>'\
      '</span>'
    end
  end

  # rubocop:disable Metrics/MethodLength
  def self.taxon_ids(ids)
    filtered_ids = ids.split(' | ').select do |id|
      id.starts_with?('NCBI') || id.starts_with?('GBIF')
    end
    filtered_ids.map do |id_string|
      id = id_string.split(':').last
      if id_string.starts_with?('NCBI')
        "<a href='https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/" \
        "wwwtax.cgi?mode=Info&id=#{id}&lvl=3'>NCBI: #{id}</a>"
      else
        "<a href='http://gbif.org/species/#{id}'>GBIF: #{id}</a>"
      end
    end.join('<br>')
  end
  # rubocop:enable Metrics/MethodLength

  def self.taxon_path(path)
    path&.gsub(' | ', ', ')
  end

  def self.total(values)
    values.map(&:second).sum
  end

  # rubocop:disable Metrics/MethodLength
  def self.cal_counts(counts, include_other = false)
    categories = %w[
      Animals Archaea Bacteria Chromista Fungi Plants
    ]

    other_count = (counts['Environmental samples'] || 0) +
                  (counts['Plants and Fungi'] || 0) +
                  (counts['Protozoa'] || 0)

    normalized_counts = {}
    categories.each do |category|
      normalized_counts[category] = if counts[category].nil?
                                      nil
                                    else
                                      counts[category]
                                    end
    end
    normalized_counts['Other'] = other_count if include_other
    normalized_counts
  end

  def self.gbif_counts(counts, include_other = false)
    categories = %w[
      Animalia Archaea Bacteria Chromista Fungi Plantae
    ]

    normalized_counts = {}
    categories.each do |category|
      normalized_counts[category] = if counts[category].nil?
                                      nil
                                    else
                                      counts[category]
                                    end
    end
    normalized_counts['Other'] = nil if include_other
    normalized_counts
  end
  # rubocop:enable Metrics/MethodLength

  def self.taxon_string(taxon)
    [
      taxon['superkingdom'], taxon['phylum'], taxon['class_name'],
      taxon['order'],
      taxon['family'], taxon['genus'], taxon['species']
    ].compact.join(', ')
  end

  def self.convert_taxa_string(string)
    taxa_array =
      string.delete('{"').delete('{').delete('"}').delete('}').split(',')
    taxa_array.map do |taxon|
      parts = taxon.split('|')
      {
        id: parts.first,
        taxonomy_string: parts.drop(1).join(', ')
      }
    end
  end

  def self.convert_taxa_ids(string)
    taxa_array =
      string.delete('{"').delete('{').delete('"}').delete('}').split(',')
    taxa_array.map do |taxon|
      taxon.split('|').first
    end.join('|')
  end
end
