# frozen_string_literal: true

# https://www.mediawiki.org/wiki/Extension:TextExtracts
module WikipediaImport
  def save_wiki_excerpts
    external_resources.find_each.with_index do |resource, i|
      delay = i * 0.2
      UpdateWikiExcerptJob.set(wait: delay.seconds).perform_later(resource)
    end
  end

  private

  def update_wiki_excerpt(resource)
    results = WikipediaApi.new.summary(resource.wiki_title)
    pages = results['query']['pages']
    page_id = pages.keys.first
    return if page_id == -1

    extract = pages[page_id]['extract']
    return if extract.blank?

    resource.wiki_excerpt = cleanup_extract(extract)
    resource.save
  end

  def cleanup_extract(extract)
    extract.strip.gsub(/<p class="mw-empty-elt">\s+<\/p>\s+/, '')
  end

  def external_resources
    @external_resources ||=
      ExternalResource.active
                      .where(source: :wikidata)
                      .where('wiki_excerpt IS NULL')
  end
end
