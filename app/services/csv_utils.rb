# frozen_string_literal: true

# code from https://stackoverflow.com/a/14695355
module CsvUtils
  COMMON_DELIMITERS = ['","', "\"\t\""].freeze

  def delimiter_detector(file)
    first_line = File.open(file.path).first
    return nil unless first_line

    counts = {}
    COMMON_DELIMITERS.each { |delim| counts[delim] = first_line.count(delim) }
    counts = counts.sort { |a, b| b[1] <=> a[1] }
    counts.size.positive? ? counts[0][0][1] : nil
  end
end
