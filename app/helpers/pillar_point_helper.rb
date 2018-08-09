# frozen_string_literal: true

module PillarPointHelper
  def self.total(values)
    values.map(&:second).sum
  end

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

  def self.inat_counts(counts)
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
end
