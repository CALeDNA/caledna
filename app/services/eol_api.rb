# frozen_string_literal: true

class EolApi
  include HTTParty
  require 'uri'

  base_uri 'eol.org/api/search'

  def initialize
    @options = { query: { exact: 1 } }
  end

  def taxa(keyword)
    self.class.get("/#{CGI.escape(keyword)}.json", @options)
  end
end
