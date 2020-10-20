# frozen_string_literal: true

class WikidataApi
  include HTTParty
  base_uri 'https://www.wikidata.org/w/api.php'

  def entities(taxon_name)
    options = {
      query: {
        action: 'wbsearchentities',
        language: 'en',
        search: taxon_name,
        format: 'json'
      }
    }
    self.class.get('/', options)
  end

  def wikipedia_page(id)
    options = {
      query: {
        action: 'wbgetentities',
        props: 'sitelinks',
        ids: id,
        sitefilter: 'enwiki',
        format: 'json'
      }
    }
    self.class.get('/', options)
  end

  def label(qid)
    options = {
      query: {
        action: 'wbgetentities',
        props: 'labels',
        ids: qid,
        languages: 'en',
        format: 'json'
      }
    }
    self.class.get('/', options)
  end
end
