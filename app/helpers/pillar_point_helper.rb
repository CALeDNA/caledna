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
    categories = CombineTaxon::KINGDOMS

    other_count = (counts[nil] || 0)

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
    categories = CombineTaxon::KINGDOMS

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
end
