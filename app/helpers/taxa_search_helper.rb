# frozen_string_literal: true

module TaxaSearchHelper
  def self.common_name(matches)
    names = matches.map do |match|
      next if match['name_class'] == 'scientific name'
      match['name']
    end.compact

    "(#{names.join(', ')})" if names.present?
  end
end
