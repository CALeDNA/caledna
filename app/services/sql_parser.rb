# frozen_string_literal: true

module SqlParser
  def parse_string_arrays(value)
    reg = /^\\?"(.*?)\\?"$/
    value.tr('{', '')
         .tr('}', '')
         .split(',')
         .map { |i| i.match?(reg) ? i.match(reg)[1] : i }
         .map { |i| numeric?(i) ? i.to_i : i }
         .map { |i| i == 'NULL' ? nil : i }
  end

  # https://stackoverflow.com/a/16976153
  # https://stackoverflow.com/a/35516719
  def numeric?(str)
    str = str.tr(',', '')
    !(str =~ /^-?\d+(\.\d*)?$/).nil?
  end
end
