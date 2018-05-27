# frozen_string_literal: true

class WikipediaApi
  include HTTParty
  base_uri 'http://en.wikipedia.org/w/api.php'

  # rubocop:disable Metrics/MethodLength
  def summary(title)
    options = {
      query: {
        action: 'query',
        prop: 'extracts',
        titles: title,
        format: 'json',
        exintro: 1,
        explaintext: 1,
        exsentences: 3
      }
    }
    self.class.get('/', options)
  end
  # rubocop:enable Metrics/MethodLength
end
