# frozen_string_literal: true

class GlobalNamesApi
  include HTTParty
  require 'uri'

  base_uri 'http://resolver.globalnames.org/name_resolvers.json'

  def names(name)
    self.class.get("?names=#{URI.encode(name)}")
  end
end
