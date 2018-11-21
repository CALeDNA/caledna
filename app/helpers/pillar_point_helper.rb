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

  def self.cal_counts(counts)
    categories = %w[
      Animals Archaea Bacteria Chromista Fungi Plants
    ]

    categories.map do |category|
      if counts[category].nil?
        ['--', nil]
      else
        [category, counts[category]]
      end
    end
  end

  def self.gbif_counts(counts)
    categories = %w[
      Animalia Archaea Bacteria Chromista Fungi Plantae
    ]

    categories.map do |category|
      if counts[category].nil?
        [category, nil]
      else
        [category, counts[category]]
      end
    end
  end
end
