# frozen_string_literal: true

class GlobalNamesApi
  include HTTParty
  require 'uri'

  base_uri 'http://resolver.globalnames.org/name_resolvers.json'

  def names(name, source_ids = nil)
    self.class.get(
      "?names=#{URI.encode(name)}&data_source_ids=#{source_ids}" \
      '&with_canonical_ranks=true&with_vernaculars=true'
    )
  end
end
