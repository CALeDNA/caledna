class KoboApi
  include HTTParty
  base_uri 'kc.kobotoolbox.org/api/v1'

  def initialize; end

  def headers
    {
      'Authorization': "Token #{ENV.fetch('KOBO_TOKEN')}"
    }
  end

  def projects
    self.class.get("/data", headers: headers)
  end
end
