# frozen_string_literal: true

# code from https://stackoverflow.com/a/14695355
module CsvUtils
  COMMON_DELIMITERS = ['","', "\"\t\"", '";"'].freeze

  def delimiter_detector(file)
    first_line = File.open(file.path).first
    return nil unless first_line

    counts = {}
    COMMON_DELIMITERS.each { |delim| counts[delim] = first_line.count(delim) }
    counts = counts.sort { |a, b| b[1] <=> a[1] }
    counts.size.positive? ? counts[0][0][1] : nil
  end

  def my_csv_read(file)
    # set encoding to handle UTF8 BOM files
    # https://stackoverflow.com/a/7780559 https://stackoverflow.com/a/6784805
    delim = delimiter_detector(file)
    CSV.read(file.path, headers: true, col_sep: delim, encoding: 'bom|utf-8')
  end
end
