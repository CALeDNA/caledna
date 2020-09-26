# frozen_string_literal: true

# https://www.mediawiki.org/wiki/Extension:TextExtracts
class WikipediaApi
  include HTTParty
  base_uri 'http://en.wikipedia.org/w/api.php'

  def summary(title)
    options = {
      query: {
        action: 'query',
        prop: 'extracts',
        titles: title,
        format: 'json',
        exintro: 2, # content from before the first section
        # explaintext: 1, # plain text instead of html
        # exchars: 800 # How many characters to return
        # exsentences: 5 # how many sentences to return
      }
    }
    self.class.get('/', options)
  end
end
