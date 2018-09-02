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

  def self.gbif_counts(counts)
    categories = [
      'Animalia', 'Archaea', 'Bacteria', 'Chromista', '--', 'Fungi',
      'Plantae', '--'
    ]

    categories.map do |category|
      if counts[category].nil?
        [category, nil]
      else
        [category, counts[category]]
      end
    end
  end

  def self.only_gbif_counts(counts)
    categories = [
      'Animalia', 'Archaea', 'Bacteria', 'Chromista', 'Fungi',
      'Plantae'
    ]

    categories.map do |category|
      if counts[category].nil?
        [category, nil]
      else
        [category, counts[category]]
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
end
