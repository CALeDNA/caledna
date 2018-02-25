# frozen_string_literal: true

class GbifApi
  include HTTParty
  require 'uri'

  base_uri 'api.gbif.org/v1'

  def initialize
    @options = {}
  end

  def datasets(id)
    self.class.get("/dataset/#{id}", @options)
  end
end
