# frozen_string_literal: true

module PillarPointHelper
  def self.total(values)
    values.map(&:second).sum
  end

  # rubocop:disable Metrics/MethodLength
  def self.cal_counts(counts)
    categories = [
      'Animals', 'Archaea', 'Bacteria', '--', 'Environmental samples', 'Fungi',
      'Plants', 'Plants and Fungi'
    ]

    categories.map do |category|
      if counts[category].nil?
        ['--', nil]
      else
        [category, counts[category]]
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def self.gbif_counts(counts)
    categories = [
      'Animalia', 'Archaea', 'Bacteria', 'Chromista', '--', 'Fungi',
      'Plantae', '--'
    ]

    categories.map do |category|
      if counts[category].nil?
        ['--', nil]
      else
        [category, counts[category]]
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
end
