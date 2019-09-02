# frozen_string_literal: true

module SqlParser
  require 'yaml'

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  def parse_string_arrays(str)
    # https://stackoverflow.com/a/17271822
    # use YAML.safe_load  to convert string arrays from raw sql queries
    # into arrays.

    # BUG: YAML.safe_load errors out when there is '?' and ':'
    # HACK: replace charcter to get through safe_load, then add it back.

    new_str = str
    converted_value = {}

    new_str = new_str.tr('?', '¿') if str.include?('?')
    new_str = new_str.tr(':', '∆') if str.include?(':')

    begin
      converted_value = YAML.safe_load(new_str)
    rescue StandardError => e
      puts ">>>> YAML error #{e}}"
      return
    end

    converted_value.keys.compact.map do |value|
      unless value.is_a? Numeric
        value = value.tr('\\\"', '')
        value = value.tr('¿', '?') if value.include?('¿')
        value = value.tr('∆', ':') if value.include?('∆')
      end
      value
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
end
